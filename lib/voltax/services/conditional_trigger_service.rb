require_relative "../money"
require_relative "../dtos/activation_context_dto"
require_relative "../repositories/conditional_order_repository"
require_relative "../repositories/market_repository"
require_relative "../repositories/trade_repository"
require_relative "order_service"
require_relative "public_feed_service"

module VoltaX
  module Services
    class ConditionalTriggerService
      DEFAULT_LIMIT = 100

      def initialize(database:)
        @database = database
      end

      def process_market(market_symbol:, last_trade_price:, limit: DEFAULT_LIMIT)
        market = active_market!(market_symbol)
        price = Money.coerce_decimal(last_trade_price)
        results = []

        database.transaction do
          conditional_order_repository.pending_trigger_candidates(
            market_id: market[:id],
            last_trade_price: price,
            limit: limit
          ).each do |candidate|
            current = conditional_order_repository.lock_pending(id: candidate[:id])
            next unless current
            next unless trigger_satisfied?(current, price)

            results << trigger_order(current, market)
          end
        end

        results
      rescue ArgumentError
        []
      end

      def process_from_latest_trades(limit: DEFAULT_LIMIT)
        latest_trade_rows.flat_map do |trade|
          market = market_repository.find_by_id(trade[:market_id])
          next [] unless market && market[:status] == "active"

          process_market(market_symbol: market[:symbol], last_trade_price: trade[:execution_price], limit: limit)
        end
      end

      private

      attr_reader :database

      def trigger_order(order, market)
        idempotency_key = trigger_idempotency_key(order)
        conditional_order_repository.transition_status(
          id: order[:id],
          from_status: "pending",
          to_status: "triggered",
          trigger_idempotency_key: idempotency_key
        )

        placed_order = order_service.place(
          user_id: order[:user_id],
          market_symbol: market[:symbol],
          side: order[:side],
          order_type: order[:order_type],
          limit_price: Money.format(order[:limit_price]),
          quantity: Money.format(order[:quantity]),
          client_order_id: order[:client_order_id],
          execution_memo: nil
        )
        placed_conditional = conditional_order_repository.transition_status(
          id: order[:id],
          from_status: "triggered",
          to_status: "placed",
          triggered_order_id: placed_order[:id]
        )
        feed_event = public_feed_service.publish_conditional_trigger(
          market_symbol: market[:symbol],
          side: order[:side],
          trigger_type: order[:trigger_type],
          trigger_price: Money.format(order[:trigger_price]),
          limit_price: Money.format(order[:limit_price]),
          quantity: Money.format(order[:quantity]),
          idempotency_key: idempotency_key,
          conditional_order_id: order[:id],
          activation_context: activation_context_for(order)
        )

        {
          status: "placed",
          conditional_order: placed_conditional,
          order: placed_order,
          feed_event: feed_event
        }
      rescue OrderService::ClientOrderIdTaken, OrderService::InsufficientFunds, OrderService::InvalidRequest
        rejected = conditional_order_repository.transition_status(
          id: order[:id],
          from_status: "triggered",
          to_status: "rejected"
        )
        {
          status: "rejected",
          conditional_order: rejected,
          order: nil,
          feed_event: nil
        }
      end

      def latest_trade_rows
        database[:trades]
          .select_group(:market_id)
          .select_append { max(public_sequence).as(:latest_sequence) }
          .order(:market_id)
          .all
          .map do |row|
            database[:trades].where(market_id: row[:market_id], public_sequence: row[:latest_sequence]).first
          end
          .compact
      end

      def active_market!(symbol)
        market = market_repository.find_by_symbol(symbol.to_s)
        raise ArgumentError unless market && market[:status] == "active"

        market
      end

      def trigger_satisfied?(order, last_trade_price)
        return last_trade_price >= order[:trigger_price] if order[:trigger_type] == "last_trade_price_at_or_above"

        last_trade_price <= order[:trigger_price]
      end

      def trigger_idempotency_key(order)
        "conditional-trigger:#{order[:id]}"
      end

      def activation_context_for(order)
        DTOs::ActivationContextDTO.render(
          signal: {
            kind: order[:trigger_type],
            threshold: Money.format(order[:trigger_price]),
            routing_profile: routing_profile_for(order),
            signal_context: order[:signal_context]
          }
        )
      end

      def routing_profile_for(order)
        [order[:order_type], order[:side], "central-book"].compact.join(":")
      end

      def market_repository
        @market_repository ||= Repositories::MarketRepository.new(database: database)
      end

      def conditional_order_repository
        @conditional_order_repository ||= Repositories::ConditionalOrderRepository.new(database: database)
      end

      def public_feed_service
        @public_feed_service ||= PublicFeedService.new(database: database)
      end

      def order_service
        @order_service ||= OrderService.new(database: database)
      end
    end
  end
end
