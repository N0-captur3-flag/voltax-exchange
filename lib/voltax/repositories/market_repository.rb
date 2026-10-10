require "bigdecimal"
require "sequel"

module VoltaX
  module Repositories
    class MarketRepository
      DEFAULT_MARKETS = [
        {
          symbol: "VOLT-USDT",
          base_asset: "VOLT",
          quote_asset: "USDT",
          tick_size: BigDecimal("0.1"),
          lot_size: BigDecimal("1"),
          status: "active"
        }
      ].freeze

      def initialize(database:)
        @database = database
      end

      def seed_default_markets!
        DEFAULT_MARKETS.each { |market| create_unless_exists(**market) }
        list
      end

      def create_unless_exists(symbol:, base_asset:, quote_asset:, tick_size:, lot_size:, status:)
        existing = find_by_symbol(symbol)
        return refresh_seed(existing, base_asset: base_asset, quote_asset: quote_asset, tick_size: tick_size, lot_size: lot_size, status: status) if existing

        timestamp = now
        id = markets.insert(
          symbol: symbol,
          base_asset: base_asset,
          quote_asset: quote_asset,
          tick_size: tick_size,
          lot_size: lot_size,
          status: status,
          created_at: timestamp,
          updated_at: timestamp
        )
        find_by_id(id)
      end

      def find_by_id(id)
        markets.where(id: id).first
      end

      def find_by_symbol(symbol)
        markets.where(symbol: symbol.to_s).first
      end

      def list
        markets.order(:symbol).all
      end

      def search_markets(query)
        text = query.to_s.strip
        raise ArgumentError, "Market search is invalid" if text.empty? || text.length > 32
        raise ArgumentError, "Market search is invalid" unless text.match?(/\A[a-zA-Z0-9 -]+\z/)

        markets
          .where(Sequel.ilike(:symbol, "%#{text}%"))
          .order(:symbol)
          .limit(25)
          .all
      end

      private

      attr_reader :database

      def refresh_seed(existing, base_asset:, quote_asset:, tick_size:, lot_size:, status:)
        attrs = {
          base_asset: base_asset,
          quote_asset: quote_asset,
          tick_size: tick_size,
          lot_size: lot_size,
          status: status
        }
        return existing if attrs.all? { |key, value| existing[key] == value }

        markets.where(id: existing[:id]).update(attrs.merge(updated_at: now))
        find_by_id(existing[:id])
      end

      def markets
        database[:markets]
      end

      def now
        Time.now.utc
      end
    end
  end
end
