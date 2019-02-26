class Services::Overseers::Exporters::ActivitiesExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*ranges)
    super(*ranges)
    @model = Activity
    @export_name = 'activities'
    @path = Rails.root.join('tmp', filename)
    @columns = ['created_by', 'account', 'company', 'company_type', 'inquiry', 'commercial_status', 'contact_name', 'purpose', 'type', 'points_discussed', 'actions_required', 'activity_date', 'created']
  end

  def call
    perform_export_later('ActivitiesExporter', @arguments)
  end

  def build_csv
    model.where('created_at >= :start_at AND created_at <= :end_at', start_at: @start_at, end_at: @end_at).order(created_at: :desc).each do |record|
      rows.push(
        created_by: record.created_by.full_name,
        account: (record.activity_account.to_s if record.activity_account.present?),
        company: (record.activity_company.to_s if record.activity_company.present?),
        company_type: record.company_type,
        inquiry: record.inquiry.try(:inquiry_number),
        commercial_status: record.inquiry.try(:commercial_status),
        contact_name: (record.contact.to_s if record.contact.present?),
        purpose: record.purpose,
        type: record.activity_type,
        points_discussed: record.points_discussed,
        actions_required: record.actions_required,
        activity_date: record.activity_date.to_date.to_s,
        created: record.created_at.to_date.to_s
                )
    end
    export = Export.create!(export_type: 65)
    generate_csv(export)
  end
end
