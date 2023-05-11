
Sidekiq.configure_server do |config|
  # Add chewy middleware from lib/sidekiq/chewy_middleware.rb
  config = YAML.load_file(Rails.root.join('config', 'sidekiq.yml'))

  config.server_middleware do |chain|
    chain.add Sidekiq::ChewyMiddleware, :atomic
  end


  config.redis = {
    url: ENV["REDIS_URL"],
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  }
end

Sidekiq.configure_client do |config|
  config = YAML.load_file(Rails.root.join('config', 'sidekiq.yml'))

  config.redis = {
    url: ENV["REDIS_URL"],
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  }
end
