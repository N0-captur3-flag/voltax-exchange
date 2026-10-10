require "openssl"
require "securerandom"

module VoltaX
  module Auth
    module Tokens
      module_function

      def generate
        SecureRandom.urlsafe_base64(32)
      end

      def digest(token, credential_key_base:)
        raise ArgumentError, "Session token is required" if token.to_s.empty?
        raise ArgumentError, "Secret key base is required" if credential_key_base.to_s.empty?

        OpenSSL::HMAC.hexdigest("SHA256", credential_key_base, token)
      end
    end
  end
end
