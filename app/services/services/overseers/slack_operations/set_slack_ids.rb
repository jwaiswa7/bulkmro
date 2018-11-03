class Services::Overseers::SlackOperations::SetSlackIds < Services::Shared::BaseService
  def initialize
    @client = Slack::Web::Client.new
  end

  def call
    Overseer.all.each do |overseer|
      begin
        slack_uid = client.users_lookupByEmail(email: overseer.email).user.id
      rescue
        slack_uid = ''
      end
      overseer.assign_attributes(:slack_uid => slack_uid)
      overseer.save!
    end
  end

  attr_accessor :client
end