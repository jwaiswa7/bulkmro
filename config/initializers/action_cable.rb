# frozen_string_literal: true

require "action_cable/subscription_adapter/redis"

ActionCable::SubscriptionAdapter::Redis.redis_connector = ->(_config) do
  Redis.new(url: ENV["REDIS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
end
