require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bulkmro
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.assets.paths << Rails.root.join('vendor', 'assets', 'node_modules')
    config.time_zone = 'Asia/Kolkata'
    config.active_record.default_timezone = :local
  end
end

# Initializing Sentry.io
Raven.configure do |config|
  config.dsn = 'https://4fafea922f6346d198b8e8a74cecf9a0:482ea4c356e54e9aa61a83223b041b2e@sentry.io/1291091'
end