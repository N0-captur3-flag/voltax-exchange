module VoltaX
  module DTOs
    module ActivationContextDTO
      PUBLIC_SIGNAL_KEYS = %w[kind threshold routing_profile].freeze

      module_function

      def render(signal:)
        {
          signal: {
            kind: signal[:kind],
            threshold: signal[:threshold],
            routing_profile: signal[:routing_profile],
            signal_context: signal[:signal_context]
          }.compact
        }
      end

      def expanded_attributes(value)
        deep_event_attributes(value)
      end

      def public_attributes(value)
        signal = value.is_a?(Hash) ? value["signal"] || value[:signal] : nil
        return {} unless signal.is_a?(Hash)

        PUBLIC_SIGNAL_KEYS.each_with_object({}) do |key, rendered|
          attribute = signal[key] || signal[key.to_sym]
          rendered["signal_#{key}"] = attribute unless attribute.nil?
        end
      end

      def deep_event_attributes(value, prefix: nil)
        return {} unless value.is_a?(Hash)

        value.each_with_object({}) do |(key, child), rendered|
          key_text = [prefix, key.to_s].compact.join("_")
          if child.is_a?(Hash)
            rendered.merge!(deep_event_attributes(child, prefix: key_text))
          else
            rendered[key_text] = child
            rendered[key.to_s] = child unless prefix.nil?
          end
        end
      end
    end
  end
end
