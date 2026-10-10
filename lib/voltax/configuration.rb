module VoltaX
  class Configuration
    class Error < StandardError; end

    ALLOWED_ENVIRONMENTS = %w[development test production].freeze
    SECRET_PLACEHOLDER_PATTERNS = [
      /replace-with/i,
      /change-me/i,
      /example/i,
      /<[^>]+>/
    ].freeze
    DEFAULT_TEST_VALUES = {
      "VOLTAX_SERVICE_NAME" => "voltax-exchange-test",
      "VOLTAX_PUBLIC_BASE_URL" => "http://example.test",
      "VOLTAX_BIND" => "127.0.0.1",
      "VOLTAX_PORT" => "9292",
      "VOLTAX_SECRET_KEY_BASE" => "test-credential-key-base-only-for-automated-tests"
    }.freeze
    REQUIRED_NON_TEST_KEYS = %w[
      VOLTAX_SERVICE_NAME
      VOLTAX_SECRET_KEY_BASE
    ].freeze
    attr_reader :environment, :service_name, :public_base_url, :bind, :port, :database_url

    def self.load(env = ENV)
      new(env).tap(&:validate!)
    end

    def initialize(env)
      @env = normalize_env(env)
      @environment = fetch("RACK_ENV", fetch("VOLTAX_ENV", "development"))
      apply_test_defaults if test?

      @service_name = fetch("VOLTAX_SERVICE_NAME", nil)
      @public_base_url = fetch("VOLTAX_PUBLIC_BASE_URL", "http://localhost:9292")
      @bind = fetch("VOLTAX_BIND", "0.0.0.0")
      @port = Integer(fetch("VOLTAX_PORT", "9292"), exception: false)
      @credential_key_base = fetch("VOLTAX_SECRET_KEY_BASE", nil)
      @database_url = fetch("VOLTAX_DATABASE_URL", fetch("DATABASE_URL", nil))
    end

    def validate!
      validate_environment!
      validate_required_keys!
      validate_port!
      validate_credential_length!
      validate_no_credential_placeholders!
      self
    end

    def test?
      environment == "test"
    end

    def credential_configured?
      present?(@credential_key_base)
    end

    private

    def normalize_env(env)
      env.each_with_object({}) do |(key, value), normalized|
        normalized[key.to_s] = value.to_s unless value.nil?
      end
    end

    def fetch(key, default)
      @env.fetch(key, default)
    end

    def apply_test_defaults
      DEFAULT_TEST_VALUES.each do |key, value|
        @env[key] = value unless present?(@env[key])
      end
    end

    def validate_environment!
      return if ALLOWED_ENVIRONMENTS.include?(environment)

      raise Error, "Invalid RACK_ENV; expected one of: #{ALLOWED_ENVIRONMENTS.join(", ")}"
    end

    def validate_required_keys!
      return if test?

      missing = REQUIRED_NON_TEST_KEYS.reject { |key| present?(@env[key]) }
      return if missing.empty?

      raise Error, "Missing required configuration: #{missing.join(", ")}"
    end

    def validate_port!
      return if port&.between?(1, 65_535)

      raise Error, "Invalid VOLTAX_PORT; expected an integer from 1 to 65535"
    end

    def validate_credential_length!
      return unless present?(@credential_key_base)
      return if @credential_key_base.length >= 32

      raise Error, "Invalid VOLTAX_SECRET_KEY_BASE; expected at least 32 characters"
    end

    def validate_no_credential_placeholders!
      return if test?

      credential_values = {
        "VOLTAX_SECRET_KEY_BASE" => @credential_key_base,
        "VOLTAX_DATABASE_URL" => @database_url
      }

      invalid_keys = credential_values.each_with_object([]) do |(key, value), keys|
        next unless present?(value)
        next unless SECRET_PLACEHOLDER_PATTERNS.any? { |pattern| value.match?(pattern) }

        keys << key
      end
      return if invalid_keys.empty?

      raise Error, "Invalid placeholder configuration: #{invalid_keys.join(", ")}"
    end

    def present?(value)
      value && !value.strip.empty?
    end
  end
end
