Slack.configure do |config|
  config.token = Settings.slack.bot_user_access_token
end

ENV['SLACK_API_TOKEN'] = Settings.slack.bot_user_access_token
