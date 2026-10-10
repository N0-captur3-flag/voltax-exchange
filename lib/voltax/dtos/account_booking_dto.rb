require_relative "helpers"

module VoltaX
  module DTOs
    module AccountBookingDTO
      module_function

      def packet(receipt)
        {
          trade_id: receipt[:trade_id],
          order_id: receipt[:order_id],
          client_order_id: receipt[:client_order_id],
          booking_ref: receipt[:client_reference],
          side: receipt[:side],
          liquidity_role: receipt[:liquidity_role],
          settlement_status: receipt[:settlement_status]
        }
      end

      def receipt(receipt)
        {
          id: receipt[:id],
          trade_id: receipt[:trade_id],
          order_id: receipt[:order_id],
          client_order_id: receipt[:client_order_id],
          booking_ref: receipt[:client_reference],
          side: receipt[:side],
          liquidity_role: receipt[:liquidity_role],
          market_symbol: receipt[:market_symbol],
          price: Helpers.money(receipt[:price]),
          quantity: Helpers.money(receipt[:quantity]),
          quote_amount: Helpers.money(receipt[:quote_amount]),
          fee_asset: receipt[:fee_asset],
          fee_amount: Helpers.money(receipt[:fee_amount]),
          debit_asset: receipt[:debit_asset],
          debit_amount: Helpers.money(receipt[:debit_amount]),
          credit_asset: receipt[:credit_asset],
          credit_amount: Helpers.money(receipt[:credit_amount]),
          settlement_status: receipt[:settlement_status],
          created_at: Helpers.iso8601(receipt[:created_at])
        }
      end
    end
  end
end
