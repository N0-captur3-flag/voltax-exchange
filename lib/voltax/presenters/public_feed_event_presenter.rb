require "json"
require_relative "../dtos/activation_context_dto"
require_relative "../dtos/public_event_dto"

module VoltaX
  module Presenters
    module PublicFeedEventPresenter
      EVENT_PAYLOAD_FIELDS = {
        "trade_executed" => %w[
          trade_id
          side
          origin
          quote_amount
        ],
        "order_book_updated" => %w[
          order_book_changed
          reason
        ],
        "rfq_settled" => %w[
          trade_id
          side
          origin
          quote_amount
        ],
        "broker_report_period_closed" => %w[
          time_bucket
          status
        ],
        "market_signal_activated" => %w[
          conditional_order_id
          side
          trigger_type
          trigger_price
          limit_price
          status
          activation_context
        ],
        "conditional_order_expired" => %w[
          side
          trigger_type
          status
        ],
        "market_tick" => %w[
          reason
        ]
      }.freeze
      ACTIVATION_CONTEXT_FIELD = "activation_context"

      module_function

      def render(event)
        DTOs::PublicEventDTO.render(event, payload: event_payload(event))
      end

      def event_payload(event)
        payload = parsed_payload(event[:payload_json])
        fields = EVENT_PAYLOAD_FIELDS.fetch(event[:event_type], [])
        payload.each_with_object({}) do |(key, value), rendered|
          key_text = key.to_s
          if key_text == ACTIVATION_CONTEXT_FIELD
            normalize_event_attributes(rendered, value)
          elsif fields.include?(key_text)
            rendered[key_text.to_sym] = value
          end
        end
      rescue JSON::ParserError
        {}
      end

      def normalize_event_attributes(rendered, value)
        return rendered unless value.is_a?(Hash)

        DTOs::ActivationContextDTO.expanded_attributes(value).each do |key, context_value|
          rendered[key.to_sym] = context_value
        end
        rendered
      end

      def deep_event_attributes(value, prefix: nil)
        DTOs::ActivationContextDTO.deep_event_attributes(value, prefix: prefix)
      end

      def parsed_payload(payload_json)
        payload_json.is_a?(Hash) ? payload_json : JSON.parse(payload_json.to_s)
      end
    end
  end
end
