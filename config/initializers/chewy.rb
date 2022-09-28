Chewy.request_strategy = :atomic if Rails.env.staging?
Chewy.logger = Logger.new(STDOUT) if Rails.env.staging?
Chewy.logger.level = Logger::INFO if Rails.env.staging?
