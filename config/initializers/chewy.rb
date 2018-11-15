Chewy.request_strategy = :atomic if Rails.env.production?
Chewy.logger = Logger.new(STDOUT)
Chewy.logger.level = Logger::INFO