require "time"

module VoltaX
  module Presenters
    module SessionPresenter
      module_function

      def render_created(session:, token:)
        render_current(session).merge(
          token_type: "bearer",
          token: token
        )
      end

      def render_current(session)
        {
          expires_at: iso8601(session[:expires_at])
        }
      end

      def iso8601(value)
        value&.to_time&.utc&.iso8601
      end
    end
  end
end
