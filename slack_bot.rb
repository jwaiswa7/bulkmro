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
            when /(inquiry\s*(\d*)|where is inquiry\s*(\d*))/i then
              "This inquiry is currently #{
              [
                  "awaiting the customer's feedback",
                  "awaiting sales manager approval",
                  "dispatched and will be delivered by *#{format_date(Time.now.noon + rand(6).days)}*"
              ].sample
              }."
            when /order status (\d*)/i then
              "This order will deliver by *#{format_date(Time.now.noon + rand(6).days)}*."
            when /account status (\d*)/i then
              "This account has *#{rand(6) + 1}* open inquiries. This is a _priority account_ with order value exceeding *₹245,000* in the past *7 days*."
            when /sales today/i then
              "*#{rand(50) + 20}* total inquires today generated *₹54,30,000* in sales."
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