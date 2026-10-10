require "time"
require "sequel"
require_relative "../account_profiles"
require_relative "../money"
require_relative "../repositories/trade_receipt_repository"

module VoltaX
  module Services
    class BrokerReportService
      class InvalidRequest < StandardError; end
      class Forbidden < StandardError; end

      def initialize(database:)
        @database = database
      end

      def trade_rows(user:, month: nil, campaign_id: nil)
        validate_broker!(user)
        dataset = base_report_dataset(broker_user_id: user[:id])
        dataset = dataset.where(Sequel[:campaigns][:id] => parse_id(campaign_id)) if campaign_id
        dataset = apply_month_filter(dataset, month) if month

        rows = dataset.order(Sequel[:campaigns][:id], Sequel[:trades][:created_at], Sequel[:trades][:public_sequence], Sequel[:receipts][:id])
          .all
        enrichment_snapshot = execution_enrichment_snapshot(rows)
        rows.map { |row| report_row_for(row, enrichment_snapshot: enrichment_snapshot) }
      rescue ArgumentError
        raise InvalidRequest
      end

      def monthly_rows(user:, month: nil, campaign_id: nil)
        rows = trade_rows(user: user, month: month, campaign_id: campaign_id)
        grouped = rows.group_by { |row| [row[:campaign_id], row[:campaign_code], row[:time_bucket]] }

        grouped.map do |(group_campaign_id, group_campaign_code, time_bucket), group_rows|
          {
            campaign_id: group_campaign_id,
            campaign_code: group_campaign_code,
            time_bucket: time_bucket,
            trade_count: group_rows.length,
            total_notional_volume: group_rows.reduce(Money.zero) { |sum, row| sum + row[:notional_volume] },
            fee_asset: nil,
            fee_amount: group_rows.reduce(Money.zero) { |sum, row| sum + row[:fee_amount] },
            rebate_asset: nil,
            rebate_amount: Money.zero
          }
        end.sort_by { |row| [row[:campaign_id], row[:time_bucket]] }
      end

      private

      attr_reader :database

      def base_report_dataset(broker_user_id:)
        database.from(Sequel.as(:broker_attributions, :attributions))
          .join(Sequel.as(:broker_campaigns, :campaigns), Sequel[:campaigns][:id] => Sequel[:attributions][:campaign_id])
          .join(Sequel.as(:trade_receipts, :receipts), Sequel[:receipts][:user_id] => Sequel[:attributions][:trader_user_id])
          .join(:trades, Sequel[:trades][:id] => Sequel[:receipts][:trade_id])
          .where(Sequel[:campaigns][:broker_user_id] => broker_user_id)
          .where(Sequel[:attributions][:status] => %w[active revoked])
          .where { Sequel[:trades][:created_at] >= Sequel[:attributions][:attributed_at] }
          .where(Sequel.|({ Sequel[:attributions][:revoked_at] => nil },
                          Sequel.expr(Sequel[:trades][:created_at] < Sequel[:attributions][:revoked_at])))
          .select(
            Sequel[:campaigns][:id].as(:campaign_id),
            Sequel[:campaigns][:campaign_code].as(:campaign_code),
            Sequel[:attributions][:id].as(:attribution_id),
            Sequel[:trades][:id].as(:trade_id),
            Sequel[:trades][:created_at].as(:traded_at),
            Sequel[:receipts][:user_id].as(:receipt_user_id),
            Sequel[:receipts][:market_symbol].as(:market_symbol),
            Sequel[:receipts][:side].as(:side),
            Sequel[:receipts][:liquidity_role].as(:liquidity_role),
            Sequel[:receipts][:price].as(:execution_price),
            Sequel[:receipts][:quantity].as(:quantity),
            Sequel[:receipts][:quote_amount].as(:notional_volume),
            Sequel[:receipts][:fee_asset].as(:fee_asset),
            Sequel[:receipts][:fee_amount].as(:fee_amount),
            Sequel[:receipts][:client_order_id].as(:client_order_id)
          )
      end

      def apply_month_filter(dataset, month)
        start_time = parse_month(month)
        end_time = next_month(start_time)
        dataset.where { Sequel[:trades][:created_at] >= start_time }
          .where { Sequel[:trades][:created_at] < end_time }
      end

      def report_row_for(row, enrichment_snapshot:)
        origin = origin_for(row[:client_order_id])
        notional_volume = Money.coerce_decimal(row[:notional_volume])
        report = {
          campaign_id: row[:campaign_id],
          campaign_code: row[:campaign_code],
          attribution_id: row[:attribution_id],
          trade_id: row[:trade_id],
          market_symbol: row[:market_symbol],
          side: row[:side],
          liquidity_role: row[:liquidity_role],
          origin: origin,
          quantity: Money.coerce_decimal(row[:quantity]),
          execution_price: Money.coerce_decimal(row[:execution_price]),
          notional_volume: notional_volume,
          fee_asset: row[:fee_asset],
          fee_amount: Money.coerce_decimal(row[:fee_amount] || Money.zero),
          rebate_asset: nil,
          rebate_amount: Money.zero,
          traded_at: row[:traded_at],
          time_bucket: time_bucket(row[:traded_at]),
          liquidity_band: liquidity_band_for(notional_volume),
          venue_code: venue_code_for(row[:market_symbol]),
          fee_tier: fee_tier_for(row),
          rebate_hint: rebate_hint_for(row),
          routing_label: routing_label_for(origin)
        }
        if origin == "orderbook"
          context = allocation_enrichment_for(row, enrichment_snapshot: enrichment_snapshot)
          report[:booking_marker] = context[:booking_marker] if context&.key?(:booking_marker)
        end
        report
      end

      def allocation_enrichment_for(row, enrichment_snapshot:)
        enrichment_snapshot[row[:trade_id]]
      end

      def execution_enrichment_snapshot(rows)
        trade_ids = rows.map { |row| row[:trade_id] }.uniq
        return {} if trade_ids.empty?

        database[:trade_receipts]
          .where(trade_id: trade_ids)
          .order(:id)
          .all
          .group_by { |receipt| receipt[:trade_id] }
          .transform_values { |receipt_rows| venue_booking_context_for(receipt_rows) }
      end

      def venue_booking_context_for(receipt_rows)
        booking_marker = receipt_rows.map { |receipt| receipt[booking_marker_column] }
          .compact
          .find { |value| !value.to_s.empty? }
        primary = receipt_rows.first
        return {} unless primary

        {
          side: primary[:side],
          liquidity_role: primary[:liquidity_role],
          settlement_status: primary[:settlement_status],
          booking_marker: booking_marker
        }.compact
      end

      def booking_marker_column
        Repositories::TradeReceiptRepository::BOOKING_MARKER_COLUMN
      end

      def liquidity_band_for(notional_volume)
        return "micro" if notional_volume < Money.coerce_decimal("10")
        return "block" if notional_volume >= Money.coerce_decimal("1000")

        "standard"
      end

      def venue_code_for(market_symbol)
        base, = market_symbol.to_s.split("-", 2)
        "VX-#{base}"
      end

      def fee_tier_for(row)
        row[:fee_asset] ? "standard" : "zero-fee"
      end

      def rebate_hint_for(row)
        row[:liquidity_role] == "maker" ? "maker-schedule" : "none"
      end

      def routing_label_for(origin)
        origin == "rfq" ? "negotiated" : "central-book"
      end

      def validate_broker!(user)
        raise Forbidden unless AccountProfiles.can?(user, "broker_reports")
      end

      def parse_id(value)
        text = value.to_s
        raise ArgumentError unless text.match?(/\A[1-9]\d*\z/)

        Integer(text, 10)
      end

      def parse_month(value)
        text = value.to_s
        match = text.match(/\A(\d{4})-(\d{2})\z/)
        raise ArgumentError unless match

        year = Integer(match[1], 10)
        month = Integer(match[2], 10)
        raise ArgumentError unless month.between?(1, 12)

        Time.utc(year, month, 1)
      end

      def next_month(time)
        return Time.utc(time.year + 1, 1, 1) if time.month == 12

        Time.utc(time.year, time.month + 1, 1)
      end

      def time_bucket(value)
        time = value.to_time.utc
        format("%04d-%02d", time.year, time.month)
      end

      def origin_for(client_order_id)
        client_order_id.to_s.start_with?("rfq-") ? "rfq" : "orderbook"
      end
    end
  end
end
