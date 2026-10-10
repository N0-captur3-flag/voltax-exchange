require "sequel"
require_relative "configuration"
require_relative "repositories/market_repository"

module VoltaX
  module DB
    class ConnectionError < StandardError; end

    MIGRATIONS_PATH = File.expand_path("../../db/migrations", __dir__).freeze

    module_function

    def connect(configuration: Configuration.load)
      database_url = configuration.database_url
      raise ConnectionError, "Missing required database configuration: VOLTAX_DATABASE_URL" unless present?(database_url)

      Sequel.connect(database_url, logger: nil, test: true)
    rescue ConnectionError
      raise
    rescue StandardError
      raise ConnectionError, "Database connection failed; verify PostgreSQL configuration"
    end

    def with_connection(configuration: Configuration.load)
      database = connect(configuration: configuration)
      yield database
    ensure
      database&.disconnect
    end

    def migrate(database:, target: nil, migrations_path: MIGRATIONS_PATH)
      Sequel.extension :migration
      options = {}
      options[:target] = target if target
      Sequel::Migrator.run(database, migrations_path, options)
    rescue StandardError
      raise ConnectionError, "Database migration failed; verify PostgreSQL migration state"
    end

    def current_version(database:)
      return database[:schema_info].get(:version) if database.table_exists?(:schema_info)
      return database[:schema_migrations].max(:filename) if database.table_exists?(:schema_migrations)

      nil
    rescue StandardError
      raise ConnectionError, "Database migration version unavailable"
    end

    def readiness(configuration: Configuration.load)
      with_connection(configuration: configuration) do |database|
        database.fetch("SELECT 1 AS ok").first
      end

      { status: "ready", checks: { postgres: "ok" } }
    rescue StandardError
      { status: "not_ready", checks: { postgres: "unavailable" } }
    end

    def seed_markets(database:)
      Repositories::MarketRepository.new(database: database).seed_default_markets!
    end

    def present?(value)
      value && !value.to_s.strip.empty?
    end
  end
end
