require_relative "../repositories/public_feed_repository"

module VoltaX
  module Services
    class PublicFeedService
      def initialize(database:)
        @repository = Repositories::PublicFeedRepository.new(database: database)
      end

      def publish_trade_executed(trade:, market_symbol:, origin: "orderbook", idempotency_key: nil)
        repository.append(
          event_type: "trade_executed",
          market_symbol: market_symbol,
          price: trade[:execution_price],
          quantity: trade[:executed_quantity],
          public_reason: "trade_executed",
          payload: {
            trade_id: trade[:id],
            side: trade[:aggressor_side],
            origin: origin,
            quote_amount: trade[:quote_amount]
          },
          idempotency_key: idempotency_key,
          reference_type: "trade",
          reference_id: trade[:id]
        )
      end

      def publish_conditional_trigger(market_symbol:, side:, trigger_type:, trigger_price:, limit_price:, quantity:,
                                      idempotency_key:, conditional_order_id: nil, activation_context: {})
        payload = {
          conditional_order_id: conditional_order_id,
          side: side,
          trigger_type: trigger_type,
          trigger_price: trigger_price,
          limit_price: limit_price,
          status: "triggered"
        }
        payload[:activation_context] = activation_context unless activation_context.empty?

        repository.append(
          event_type: "market_signal_activated",
          market_symbol: market_symbol,
          price: limit_price,
          quantity: quantity,
          public_reason: "market_signal_activated",
          payload: payload,
          idempotency_key: idempotency_key,
          reference_type: "conditional_order",
          reference_id: conditional_order_id || idempotency_key
        )
      end

      def publish_conditional_expiry(market_symbol:, side:, trigger_type:, idempotency_key:)
        repository.append(
          event_type: "conditional_order_expired",
          market_symbol: market_symbol,
          public_reason: "conditional_order_expired",
          payload: {
            side: side,
            trigger_type: trigger_type,
            status: "expired"
          },
          idempotency_key: idempotency_key,
          reference_type: "conditional_order",
          reference_id: idempotency_key
        )
      end

      def list(market_symbol: nil, since_sequence: 0, limit: Repositories::PublicFeedRepository::DEFAULT_LIMIT)
        repository.list(market_symbol: market_symbol, since_sequence: since_sequence, limit: limit)
      end

      def tail_sequence(market_symbol: nil)
        repository.tail_sequence(market_symbol: market_symbol)
      end

      def publish_market_tick(market_symbol:, price:, quantity: nil, idempotency_key:, reason: "deterministic_tick")
        repository.append(
          event_type: "market_tick",
          market_symbol: market_symbol,
          price: price,
          quantity: quantity,
          public_reason: "market_tick",
          payload: {
            reason: reason
          },
          idempotency_key: idempotency_key,
          reference_type: "market_tick",
          reference_id: idempotency_key
        )
      end

      private

      attr_reader :repository
    end
  end
end
