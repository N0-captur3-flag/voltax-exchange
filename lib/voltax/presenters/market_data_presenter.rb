require "time"
require_relative "../money"

module VoltaX
  module Presenters
    module MarketDataPresenter
      module_function

      def render_ticker(ticker)
        {
          market_symbol: ticker[:market_symbol],
          last_price: optional_money(ticker[:last_price]),
          best_bid: optional_money(ticker[:best_bid]),
          best_ask: optional_money(ticker[:best_ask]),
          volume: Money.format(ticker[:volume]),
          quote_volume: Money.format(ticker[:quote_volume]),
          trade_count: ticker[:trade_count]
        }
      end

      def render_candle(candle)
        {
          market_symbol: candle[:market_symbol],
          interval: candle[:interval],
          started_at: iso8601(candle[:started_at]),
          ended_at: iso8601(candle[:ended_at]),
          open: Money.format(candle[:open]),
          high: Money.format(candle[:high]),
          low: Money.format(candle[:low]),
          close: Money.format(candle[:close]),
          volume: Money.format(candle[:volume]),
          quote_volume: Money.format(candle[:quote_volume]),
          trade_count: candle[:trade_count]
        }
      end

      def render_user_trade(row)
        receipt = row.fetch(:receipt)
        {
          id: row.fetch(:trade)[:id],
          market_symbol: receipt[:market_symbol],
          side: receipt[:side],
          liquidity_role: receipt[:liquidity_role],
          order_id: receipt[:order_id],
          client_order_id: receipt[:client_order_id],
          price: Money.format(receipt[:price]),
          quantity: Money.format(receipt[:quantity]),
          quote_amount: Money.format(receipt[:quote_amount]),
          fee_asset: receipt[:fee_asset],
          fee_amount: Money.format(receipt[:fee_amount]),
          debit_asset: receipt[:debit_asset],
          debit_amount: Money.format(receipt[:debit_amount]),
          credit_asset: receipt[:credit_asset],
          credit_amount: Money.format(receipt[:credit_amount]),
          settlement_status: receipt[:settlement_status],
          created_at: iso8601(receipt[:created_at])
        }
      end

      def optional_money(value)
        value.nil? ? nil : Money.format(value)
      end

      def iso8601(value)
        value&.to_time&.utc&.iso8601
      end
    end
  end
end
