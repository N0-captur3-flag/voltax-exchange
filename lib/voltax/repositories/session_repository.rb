require_relative "../auth/tokens"

module VoltaX
  module Repositories
    class SessionRepository
      SESSION_TTL_SECONDS = 86_400

      def initialize(database:, credential_key_base:)
        @database = database
        @credential_key_base = credential_key_base
      end

      def create(user_id:, token: Auth::Tokens.generate, expires_at: nil)
        timestamp = now
        expires_at ||= timestamp + SESSION_TTL_SECONDS
        token_digest = Auth::Tokens.digest(token, credential_key_base: credential_key_base)
        id = sessions.insert(
          user_id: user_id,
          token_digest: token_digest,
          expires_at: expires_at,
          revoked_at: nil,
          created_at: timestamp,
          updated_at: timestamp
        )

        { token: token, session: find_by_id(id) }
      end

      def find_by_id(id)
        sessions.where(id: id).first
      end

      def find_by_token(token, at: now)
        sessions.where(
          token_digest: Auth::Tokens.digest(token, credential_key_base: credential_key_base),
          revoked_at: nil
        ).where { expires_at > at }.first
      end

      def revoke(token, at: now)
        sessions.where(
          token_digest: Auth::Tokens.digest(token, credential_key_base: credential_key_base),
          revoked_at: nil
        ).update(revoked_at: at, updated_at: at)
      end

      private

      attr_reader :database, :credential_key_base

      def sessions
        database[:sessions]
      end

      def now
        Time.now.utc
      end
    end
  end
end
