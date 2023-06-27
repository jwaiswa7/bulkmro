# config/initializers/redis_config.rb
require "action_cable/subscription_adapter/redis"

def redis_url
  ENV["REDIS_URL"]
end

def redis_ssl_params
  { verify_mode: OpenSSL::SSL::VERIFY_NONE }
end

$redis = Redis.new(url: redis_url, ssl_params: redis_ssl_params)

p "debug---"*88
p $redis
p "debug---"*88

def configure_action_cable
  ActionCable::SubscriptionAdapter::Redis.redis_connector = ->(_config) do
    $redis
  end
end

def configure_sidekiq
  Sidekiq.default_job_options = { 'retry' => 5 }

  Sidekiq.configure_server do |config|
    # Add chewy middleware from lib/sidekiq/chewy_middleware.rb
    config.server_middleware do |chain|
      chain.add Sidekiq::ChewyMiddleware, :atomic
    end

    config.redis = {
      url: redis_url,
      ssl_params: redis_ssl_params
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: redis_url,
      ssl_params: redis_ssl_params
    }
  end
end

configure_action_cable
configure_sidekiq
