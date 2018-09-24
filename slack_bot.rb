require_relative './config/boot'
require_relative './config/environment'
include DisplayHelper

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end


client.on :message do |data|
  user = "<@#{data.user}>"

  puts data
  message = case data.text
  when /(hey|hi|hello)/i then
    "Howdy #{user}!"
  when /inquiry\s*(\d*)/i then
    "This inquiry is currently #{
      [
          "awaiting the customer's feedback",
          "awaiting sales manager approval",
          "dispatched and will be delivered by #{format_date(Time.now.noon + rand(6).days)}"
      ].sample
    }."
  else
    "What's that #{user}? Say it again, this time I'll get it, I promise."
  end

  client.message channel: data.channel, text: message
end

client.on :close do |_data|
  puts "Client is about to disconnect"
end

client.on :closed do |_data|
  puts "Client has disconnected successfully"
end

client.start!