Chewy.request_strategy = :sidekiq if Rails.env.production?
# Chewy.logger = Logger.new(STDOUT)
# Chewy.logger.level = Logger::INFO