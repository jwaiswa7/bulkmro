class SprintLog
  LogFile = Rails.root.join('log', 'sprint.log')
  class << self
    attr_accessor :logger
    delegate :debug, :info, :warn, :error, :fatal, :to => :logger
  end
end