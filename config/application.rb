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
    config.autoload_paths += Dir["#{Rails.root}/lib"]
    config.time_zone = 'Mumbai'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    #Testing configuration for a specific domain
    config.session_store :cookie_store, key: '_bulkmro_session', same_site: :none, secure: true

    config.middleware.insert 0, Rack::UTF8Sanitizer
  end
end
