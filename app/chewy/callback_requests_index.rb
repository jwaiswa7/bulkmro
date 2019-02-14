# frozen_string_literal: true

class CallbackRequestsIndex < BaseIndex
  callback_resources = CallbackRequest.resources
  define_type CallbackRequest.all do
    field :id, type: 'integer'
    field :resource_id, value: -> (record) { callback_resources[record.resource] }
    field :resource, value: -> (record) { record.resource }
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end
