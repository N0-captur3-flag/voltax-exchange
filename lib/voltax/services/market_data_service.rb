require "time"
require_relative "../money"
require_relative "../repositories/market_repository"
require_relative "../repositories/trade_repository"
require_relative "order_service"

module VoltaX
  module Services
    class MarketDataService
      class InvalidRequest < StandardError; end

      INTERVALS = {
        "1m" => 60,
        "5m" => 300,
        "1h" => 3600
      }.freeze
      DEFAULT_LIMIT = 100
      MAX_LIMIT = 500

      def initialize(database:)
        @database = database
      end

      def ticker(market_symbol:)
        market = active_market!(market_symbol)
        trades = trade_repository.list_for_market(market_id: market[:id])
        book = order_service.orderbook(market_symbol: market[:symbol])
        last_trade = trades.last

        {
          market_symbol: market[:symbol],
          last_price: last_trade && last_trade[:execution_price],
          best_bid: book.fetch(:bids).first&.fetch(:price),
          best_ask: book.fetch(:asks).first&.fetch(:price),
          volume: trades.reduce(Money.zero) { |sum, trade| sum + Money.coerce_decimal(trade[:executed_quantity]) },
          quote_volume: trades.reduce(Money.zero) { |sum, trade| sum + Money.coerce_decimal(trade[:quote_amount]) },
          trade_count: trades.length
        }
      rescue ArgumentError, Services::OrderService::InvalidRequest
        raise InvalidRequest
      end

      def public_ticker_snapshot(symbol)
        ticker(market_symbol: symbol)
      end

      def candles(market_symbol:, interval: "1m", limit: DEFAULT_LIMIT)
        market = active_market!(market_symbol)
        seconds = interval_seconds(interval)
        limit = parse_limit(limit)
        grouped = trade_repository.list_for_market(market_id: market[:id]).group_by do |trade|
          bucket_start(trade[:created_at], seconds)
        end

        grouped.keys.sort.last(limit).map do |started_at|
          rows = grouped.fetch(started_at).sort_by { |trade| trade[:public_sequence] }
          prices = rows.map { |trade| Money.coerce_decimal(trade[:execution_price]) }
          {
            market_symbol: market[:symbol],
            interval: interval,
            started_at: started_at,
            ended_at: started_at + seconds,
            open: prices.first,
            high: prices.max,
            low: prices.min,
            close: prices.last,
            volume: rows.reduce(Money.zero) { |sum, trade| sum + Money.coerce_decimal(trade[:executed_quantity]) },
            quote_volume: rows.reduce(Money.zero) { |sum, trade| sum + Money.coerce_decimal(trade[:quote_amount]) },
            trade_count: rows.length
          }
        end
      rescue ArgumentError
        raise InvalidRequest
      end

      def user_trades(user:)
        database[:trade_receipts].where(user_id: user[:id]).order(:id).all.filter_map do |receipt|
          trade = trade_repository.find_by_id(receipt[:trade_id])
          next unless trade

          { trade: trade, receipt: receipt }
        end
      end

      private

      attr_reader :database

      def active_market!(symbol)
        market = market_repository.find_by_symbol(symbol.to_s)
        raise ArgumentError unless market && market[:status] == "active"

        market
      end

      def interval_seconds(interval)
        INTERVALS.fetch(interval.to_s) { raise ArgumentError }
      end

      def parse_limit(value)
        text = value.to_s
        raise ArgumentError unless text.match?(/\A[1-9]\d*\z/)

        limit = Integer(text, 10)
        raise ArgumentError if limit > MAX_LIMIT

        limit
      end

      def bucket_start(value, seconds)
        timestamp = value.to_time.utc.to_i
        Time.at(timestamp - (timestamp % seconds)).utc
      end

      def market_repository
        @market_repository ||= Repositories::MarketRepository.new(database: database)
      end

      def trade_repository
        @trade_repository ||= Repositories::TradeRepository.new(database: database)
      end

      def order_service
        @order_service ||= OrderService.new(database: database)
      end
    end
  end
end
