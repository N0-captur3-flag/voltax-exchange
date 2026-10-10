require "digest"

require_relative "../money"
require_relative "../repositories/market_repository"
require_relative "conditional_trigger_service"
require_relative "public_feed_service"

module VoltaX
  module Services
    class MarketSimulatorService
      DEFAULT_SEED = "voltax-market-demo".freeze
      DEFAULT_SYMBOL = "VOLT-USDT".freeze
      REFERENCE_PRICE = BigDecimal("100").freeze
      SPREAD = BigDecimal("1").freeze

      def initialize(database:)
        @database = database
      end

      def deterministic_tick(market_symbol: DEFAULT_SYMBOL, tick_index: 0, seed: DEFAULT_SEED)
        market = active_market!(market_symbol)
        tick_index = normalize_tick_index(tick_index)
        digest = Digest::SHA256.hexdigest("#{seed}:#{market[:symbol]}:#{tick_index}")
        ticks = digest[0, 8].to_i(16) % 11
        offset = (Money.coerce_decimal(market[:tick_size]) * ticks) - (SPREAD / 2)
        price = REFERENCE_PRICE + offset
        aligned_price = price - (price % Money.coerce_decimal(market[:tick_size]))

        {
          market_symbol: market[:symbol],
          tick_index: tick_index,
          seed: seed.to_s,
          price: aligned_price,
          quantity: Money.coerce_decimal("1.00000000")
        }
      end

      def run_once(market_symbol: DEFAULT_SYMBOL, tick_index: 0, seed: DEFAULT_SEED, trigger_conditionals: true)
        tick = deterministic_tick(market_symbol: market_symbol, tick_index: tick_index, seed: seed)
        idempotency_key = "market-tick:#{tick[:seed]}:#{tick[:market_symbol]}:#{tick[:tick_index]}"
        event = public_feed_service.publish_market_tick(
          market_symbol: tick[:market_symbol],
          price: Money.format(tick[:price]),
          quantity: Money.format(tick[:quantity]),
          idempotency_key: idempotency_key
        )
        triggers = if trigger_conditionals
          conditional_trigger_service.process_market(
            market_symbol: tick[:market_symbol],
            last_trade_price: tick[:price]
          )
        else
          []
        end

        {
          tick: tick,
          feed_event: event,
          triggers: triggers
        }
      end

      def next_tick_index(market_symbol: DEFAULT_SYMBOL, seed: DEFAULT_SEED)
        market = active_market!(market_symbol)
        prefix = "market-tick:#{seed}:#{market[:symbol]}:"
        rows = database[:public_feed_events]
          .where(event_type: "market_tick", market_symbol: market[:symbol])
          .where(Sequel.like(:idempotency_key, "#{prefix}%"))
          .reverse_order(:sequence)
          .limit(100)
          .select(:idempotency_key)
          .all
        indexes = rows.filter_map do |row|
          row[:idempotency_key].to_s.delete_prefix(prefix).then do |value|
            value.match?(/\A\d+\z/) ? Integer(value, 10) : nil
          end
        end

        indexes.empty? ? 0 : indexes.max + 1
      end

      private

      attr_reader :database

      def active_market!(symbol)
        market = market_repository.find_by_symbol(symbol.to_s)
        raise ArgumentError, "Market is invalid" unless market && market[:status] == "active"

        market
      end

      def normalize_tick_index(value)
        text = value.to_s
        raise ArgumentError, "Tick index is invalid" unless text.match?(/\A\d+\z/)

        Integer(text, 10)
      end

      def market_repository
        @market_repository ||= Repositories::MarketRepository.new(database: database)
      end

      def public_feed_service
        @public_feed_service ||= PublicFeedService.new(database: database)
      end

      def conditional_trigger_service
        @conditional_trigger_service ||= ConditionalTriggerService.new(database: database)
      end
    end
  end
end
