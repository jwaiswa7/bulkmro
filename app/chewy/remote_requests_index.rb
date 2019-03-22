class RemoteRequestsIndex < BaseIndex
  resource_status = RemoteRequest.resources

  define_type RemoteRequest.all do
    field :id, type: 'integer'
    field :request, value: -> (record) { record.manage_remote_request_data(record) }, analyzer: 'substring'
    field :resource_id, value: ->(record) { resource_status[record.resource] }
    field :resource, value: -> (record) { record.resource }, analyzer: 'substring'
    field :subject, value: -> (record) { record.subject.to_s }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_id, value: ->(record) { record.created_by_id if record.created_by_id.present? }
    field :created_by, value: ->(record) { record.created_by.first_name + ' ' + record.created_by.last_name if record.created_by_id.present? }
  end
end
