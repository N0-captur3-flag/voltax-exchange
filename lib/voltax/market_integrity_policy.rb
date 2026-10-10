# frozen_string_literal: true

module VoltaX
  module MarketIntegrityPolicy
    DEFAULT_CLIENT_TEXT_LIMIT = 512
    SHORT_CLIENT_TEXT_LIMIT = 128
    BOARD_COMMENT_LIMIT = 256
    CLIENT_TEXT_CONTROL_PATTERN = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/.freeze
    BROKER_ASSIGNMENT_KEYS = %w[
      user_id trader_user_id broker_user_id attributed_user_id account_profile status source
      password password_hash session token token_digest wallet_id ledger_id
    ].freeze
    PUBLIC_EVENT_TEXT_MARKERS = %w[
      password
      password_hash
      session
      session_id
      token
      token_digest
      database_url
      backtrace
      stack
      raw
      orm
    ].freeze

    module_function

    def optional_client_text(value, field:, max: DEFAULT_CLIENT_TEXT_LIMIT)
      return nil if value.nil?

      normalize_client_text(value, field: field, max: max, required: false)
    end

    def required_client_text(value, field:, max: DEFAULT_CLIENT_TEXT_LIMIT)
      normalize_client_text(value, field: field, max: max, required: true)
    end

    def ensure_assignment_payload!(payload, blocked_keys: BROKER_ASSIGNMENT_KEYS)
      raise ArgumentError, "Assignment payload is invalid" unless payload.is_a?(Hash)

      keys = payload.keys.map(&:to_s)
      raise ArgumentError, "Assignment payload includes reserved fields" unless (keys & blocked_keys).empty?

      true
    end

    def ensure_public_event_text!(value)
      text = value.to_s
      raise ArgumentError, "Public event text is invalid" if client_text_control?(text)

      normalized = text.downcase
      raise ArgumentError, "Public event text is invalid" if PUBLIC_EVENT_TEXT_MARKERS.any? { |marker| normalized.include?(marker) }

      true
    end

    def client_text_control?(text)
      CLIENT_TEXT_CONTROL_PATTERN.match?(text.to_s)
    end

    def normalize_client_text(value, field:, max:, required:)
      text = required ? value.to_s.strip : value.to_s
      raise ArgumentError, "#{field} is required" if required && text.empty?
      raise ArgumentError, "#{field} is invalid" if text.length > max
      raise ArgumentError, "#{field} is invalid" if client_text_control?(text)

      text
    end
  end
end
