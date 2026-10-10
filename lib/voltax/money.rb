require "bigdecimal"

module VoltaX
  module Money
    SCALE = 8
    MAX_INTEGER_DIGITS = 28
    DECIMAL_PATTERN = /\A-?(?:0|[1-9]\d*)(?:\.(\d{1,8}))?\z/.freeze

    module_function

    def parse(value)
      raise ArgumentError, "Money value must be a decimal string" unless value.is_a?(String)

      text = value
      raise ArgumentError, "Money value is invalid" unless text.match?(DECIMAL_PATTERN)
      raise ArgumentError, "Money value is invalid" if negative_zero?(text)

      integer_part = text.delete_prefix("-").split(".", 2).first
      raise ArgumentError, "Money value exceeds precision" if integer_part.length > MAX_INTEGER_DIGITS

      BigDecimal(text)
    end

    def format(value)
      decimal = coerce_decimal(value)
      text = decimal.to_s("F")
      raise ArgumentError, "Money value exceeds scale" if fractional_digits(text) > SCALE

      whole, fractional = text.split(".", 2)
      fractional = fractional.to_s.ljust(SCALE, "0")
      "#{whole}.#{fractional}"
    end

    def zero
      BigDecimal("0")
    end

    def positive?(value)
      coerce_decimal(value).positive?
    end

    def negative?(value)
      coerce_decimal(value).negative?
    end

    def non_negative?(value)
      !negative?(value)
    end

    def coerce_decimal(value)
      return value if value.is_a?(BigDecimal)
      return parse(value) if value.is_a?(String)

      raise ArgumentError, "Money value must be BigDecimal or decimal string"
    end

    def fractional_digits(text)
      text.include?(".") ? text.split(".", 2).last.length : 0
    end

    def negative_zero?(text)
      text.start_with?("-") && BigDecimal(text).zero?
    end

    private_class_method :fractional_digits, :negative_zero?
  end
end
