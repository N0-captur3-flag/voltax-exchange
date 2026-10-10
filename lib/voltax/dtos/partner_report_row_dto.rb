require_relative "helpers"

module VoltaX
  module DTOs
    module PartnerReportRowDTO
      module_function

      def trade(row)
        rendered = {
          campaign_id: row[:campaign_id],
          campaign_code: row[:campaign_code],
          attribution_id: row[:attribution_id],
          trade_id: row[:trade_id],
          market_symbol: row[:market_symbol],
          side: row[:side],
          liquidity_role: row[:liquidity_role],
          origin: row[:origin],
          quantity: Helpers.money(row[:quantity]),
          execution_price: Helpers.money(row[:execution_price]),
          notional_volume: Helpers.money(row[:notional_volume]),
          fee_asset: row[:fee_asset],
          fee_amount: Helpers.money(row[:fee_amount]),
          rebate_asset: row[:rebate_asset],
          rebate_amount: Helpers.money(row[:rebate_amount]),
          traded_at: Helpers.iso8601(row[:traded_at]),
          time_bucket: row[:time_bucket],
          liquidity_band: row[:liquidity_band],
          venue_code: row[:venue_code],
          fee_tier: row[:fee_tier],
          rebate_hint: row[:rebate_hint],
          routing_label: row[:routing_label]
        }
        rendered[:booking_marker] = row[:booking_marker] if row.key?(:booking_marker)
        rendered
      end

      def monthly(row)
        {
          campaign_id: row[:campaign_id],
          campaign_code: row[:campaign_code],
          time_bucket: row[:time_bucket],
          trade_count: row[:trade_count],
          total_notional_volume: Helpers.money(row[:total_notional_volume]),
          fee_asset: row[:fee_asset],
          fee_amount: Helpers.money(row[:fee_amount]),
          rebate_asset: row[:rebate_asset],
          rebate_amount: Helpers.money(row[:rebate_amount])
        }
      end
    end
  end
end
