class BibleUploadsIndex < BaseIndex
  statuses = BibleUpload.statuses
  import_types = BibleUpload.import_types

  define_type BibleUpload.all do
    field :id, type: 'integer'
    field :status_string, value: -> (record) { record.status.to_s }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.status] }, type: 'integer'
    field :import_type_string, value: -> (record) { record.import_type.to_s }, analyzer: 'substring'
    field :import_type, value: -> (record) { import_types[record.import_type] }, type: 'integer'
    field :created_at, type: 'date'
  end
end
