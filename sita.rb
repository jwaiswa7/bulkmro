# The gem 'wit' has been removed as on 16-07-2019
# Please add the gem in order to use this service

require 'wit'
require_relative './config/../config/environment'

client = Wit.new(access_token: Settings.wit.auth_token)
client.interactive

def first_entity_value(entities, entity)
  return nil unless entities.has_key? entity
  val = entities[entity][0]['value']
  return nil if val.nil?
  return val
end

def handle_message(response)
  entities = response['entities']
  entity = first_entity_value(entities, 'entity')
  intent = first_entity_value(entities, 'intent')
  greetings = first_entity_value(entities, 'greetings')
  number = first_entity_value(entities, 'number')

  case
  when intent
    return data(intent, entity, number)
  when greetings
    return "Hi! Try something like 'What's the status of order 29313?'"
  else
    return 'Ah, a little bit too fast for me. Try again?'
  end
end

def data(intent, entity, variable)
  return "You want to look up the '#{intent}' for '#{entity}' with '#{variable}'? "
end

client = Wit.new(access_token: Settings.wit.auth_token)
client.interactive(method(:handle_message))
