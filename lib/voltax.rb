require_relative "voltax/configuration"
require_relative "voltax/namespaces"
require_relative "voltax/version"
require_relative "voltax/web/application"

module VoltaX
  def self.app(env: ENV)
    Web::Application.for_configuration(Configuration.load(env))
  end
end
