module VoltaX
  module DTOs
    module VenueAllocationDTO
      module_function

      def notice(receipt)
        public_notice(receipt).merge(
          desk_ref: receipt[:client_reference]
        )
      end

      def public_notice(receipt)
        {
          side: receipt[:side],
          liquidity_role: receipt[:liquidity_role],
          settlement_status: receipt[:settlement_status]
        }
      end
    end
  end
end
