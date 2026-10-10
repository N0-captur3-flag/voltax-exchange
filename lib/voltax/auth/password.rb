require "bcrypt"

module VoltaX
  module Auth
    module Password
      MIN_LENGTH = 12

      module_function

      def hash(password, environment: ENV.fetch("RACK_ENV", "development"))
        validate!(password)
        BCrypt::Password.create(password, cost: cost_for(environment)).to_s
      end

      def verify?(password, password_hash)
        return false unless password_hash

        BCrypt::Password.new(password_hash) == password.to_s
      rescue BCrypt::Errors::InvalidHash
        false
      end

      def cost_for(environment)
        environment == "test" ? 4 : 12
      end

      def validate!(password)
        if password.to_s.length < MIN_LENGTH
          raise ArgumentError, "Password must be at least #{MIN_LENGTH} characters"
        end
      end
    end
  end
end
