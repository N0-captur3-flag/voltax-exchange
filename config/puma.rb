rackup "config.ru"
environment ENV.fetch("RACK_ENV", ENV.fetch("VOLTAX_ENV", "development"))
threads_count = Integer(ENV.fetch("PUMA_THREADS", 5))
threads threads_count, threads_count
bind "tcp://#{ENV.fetch("VOLTAX_BIND", "0.0.0.0")}:#{ENV.fetch("VOLTAX_PORT", "9292")}"
