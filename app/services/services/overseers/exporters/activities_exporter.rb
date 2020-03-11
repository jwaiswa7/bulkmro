class Services::Overseers::Exporters::ActivitiesExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @export_name = 'activities'
    @model = Activity
    @path = Rails.root.join('tmp', filename)
    @columns = ['created_by', 'account', 'company', 'company_type', 'inquiry', 'commercial_status', 'contact_name', 'purpose', 'type', 'points_discussed', 'actions_required', 'misc_expences', 'activity_date', 'created']
  end

  def call
    perform_export_later('ActivitiesExporter', @arguments)
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name,true,@export_time).deliver_now
    if @ids.present?
      records = model.where(id: @ids).order(created_at: :desc)
    else
      records = model.where('created_at >= :start_at AND created_at <= :end_at', start_at: @start_at, end_at: @end_at).order(created_at: :desc)
    end

    @export = Export.create!(export_type: 55, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    records.find_each(batch_size: 100) do |record|
      name = record.created_by.present? ? record.created_by.full_name : record.id
      rows.push(
        created_by: name,
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
        misc_expences: record.expenses,
        activity_date: record.activity_date.to_date.to_s,
        created: record.created_at.to_date.to_s
                )
    end
    # filtered = @ids.present?
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
