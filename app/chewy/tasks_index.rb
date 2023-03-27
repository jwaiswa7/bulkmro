class TasksIndex < BaseIndex
  departments = Task.departments
  statuses = Task.statuses
  priorities = Task.priorities

  define_type Task.all do
    field :id, type: 'integer'
    field :task_id, value: -> (record) {record.task_id.to_s} ,analyzer: 'substring'
    field :status_key, value: -> (record) {statuses[record.status]} , type: 'integer'
    field :status, value: -> (record) {record.status}
    field :priority_key, value: -> (record) {priorities[record.priority]} , type: 'integer'
    field :priority, value: -> (record) {record.priority}
    field :company_id, value: -> (record) {record.company.id if record.company.present?}, type: 'integer'
    field :company_name, value: -> (record) {record.company.to_s}, analyzer: 'substring'
    field :department_key, value: -> (record) {departments[record.department]} , type: 'integer'
    field :department, value: -> (record) {record.department}
    field :assignees, value: -> (record) {record.overseers.pluck(:id).uniq} , fielddata: true
    field :created_by_id, value: -> (record) {record.created_by.id if record.created_by.present?}, type: 'integer'
    field :test, value: -> (record) {1}, type: 'integer'

    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end




