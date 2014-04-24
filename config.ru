require './app.rb'
require 'redmon'

Redmon.configure do |config|
  config.redis_url = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379')
  config.namespace = 'redmon'
end

map '/' do
  if EM.reactor_running?
    Redmon::Worker.new.run!
  else
    fork do
      trap('INT') { EM.stop }
      trap('TERM') { EM.stop }
      EM.run { Redmon::Worker.new.run! }
    end
  end

  run Redmon::App
end
