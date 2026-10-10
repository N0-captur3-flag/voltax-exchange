begin
  require "bundler/setup"
rescue LoadError
  warn "Bundler is not available; install dependencies with `bundle install` before booting VoltaX."
end

require "dotenv/load" unless ENV["RACK_ENV"] == "test"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "voltax"
