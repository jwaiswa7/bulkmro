require 'slack-ruby-bot'
include DisplayHelper

class Services::Slack::Sita < SlackRubyBot::Bot
  help do
    title 'Sita'
    desc 'She is the sister you always wanted.'

    command 'inquiries today' do
      desc "Tells you how many inquiries were handled today."
    end

    command 'inquiry <inquiry number>' do
      desc 'Tells you about a particular inquiry.'
    end

    command 'sales order <order number>' do
      desc 'Tells you about a particular sales order.'
    end
  end

  def self.set_user(data)
    @user = "<@#{data.user}>"
  end

  match /(hello|hi|hey)/i do |client, data, match|
    set_user(data)

    client.say(text: "Hi #{@user}!", channel: data.channel)
  end

  match /inquiries today/i do |client, data, match|
    set_user(data)

    client.say(text: [
        "#{Inquiry.today.all.size} inquiries were created today.",
        "#{Inquiry.updated_today.all.size} inquiries were updated today."
    ].join("\n"), channel: data.channel)
  end


  match /inquiry (?<inquiry_number>\w*)/i do |client, data, match|
    set_user(data)
    id = match[:inquiry_number]

    inquiry = Inquiry.find_by_inquiry_number(id)

    if inquiry.present?
      client.say(text: [
          "The status of inquiry number _#{id}_ is _#{inquiry.status}_.",
          "It has #{inquiry.inquiry_products.size} unique products.",
          "It was created on #{format_date(inquiry.created_at)} and last updated on #{format_date(inquiry.updated_at)}.",
      ].join("\n"), channel: data.channel)
    else
      client.say(text: "Inquiry number _#{id}_ does not exist.", channel: data.channel)
    end
  end

  match /sales order (?<order_number>\w*)/i do |client, data, match|
    set_user(data)
    id = match[:order_number]

    sales_order = SalesOrder.find_by_order_number(id)

    if sales_order.present?
      client.say(text: "The status of sales order number _#{id}_ is _#{sales_order.status}_", channel: data.channel)
    else
      client.say(text: "Sales order number _#{id}_ does not exist.", channel: data.channel)
    end
  end
end
