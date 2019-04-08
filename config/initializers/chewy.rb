Chewy.request_strategy = :atomic if Rails.env.production?
Chewy.logger = Logger.new(STDOUT) if Rails.env.production?
Chewy.logger.level = Logger::INFO if Rails.env.production?