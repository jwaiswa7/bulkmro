require 'slack-ruby-bot'

class TestBot < SlackRubyBot::Bot
  help do
    title 'Inventory Bot'
    desc 'This bot lets you create, read, update, and delete items from an inventory.'

    command 'read' do
      desc 'Get inventory status for an item.'
    end

    command 'Inquiry' do
      desc 'Get inventory status for an item.'
    end

    command 'Quote' do
      desc 'Get inventory status for an item.'
    end
  end

  command '' do |client, data, match|
    client.say(text: "_It works!_", channel: data.channel)
  end

  command 'Hello','Hi','Hey' do |client, data, match|
    client.say(text: "_Hi human!_", channel: data.channel)
  end

  command 'Inquiry created' do |client, data, match|
    client.say(text: "_It works!_", channel: data.channel)
  end

  match /^[i|I]+nquiry (?<number>\w*)/ do |client, data, match|
    @db = ActiveRecord::Base.connection

    results = @db.exec_query("SELECT * FROM inquiries where inquiry_number = #{match[:number]}")
    a = []
    results.each do |row|
      a << { status: row['status'] }
    end
    client.say(text: a, channel: data.channel)
  end
end