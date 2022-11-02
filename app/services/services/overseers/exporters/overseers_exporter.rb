class Services::Overseers::Exporters::OverseersExporter < Services::Overseers::Exporters::BaseExporter
    def initialize(*params)
      super(*params)
  
      @model = Overseer
      @export_name = 'overseers'
      @path = Rails.root.join('tmp', filename)
      @columns = ['id','name', 'email','contact','role', 'active', 'created At' ]
    end
  
    def call
      perform_export_later('OverseersExporter', @arguments)
    end
  
    def build_csv
      @export_time['creation'] = Time.now
      ExportMailer.export_notification_mail(@export_name,true,@export_time).deliver_now
      if @ids.present?
        records = model.where(id: @ids)
      else
        records = model
      end
      @export = Export.create!(export_type: 120, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
      records.all.order(created_at: :desc).find_each(batch_size: 100) do |record|
        rows.push(
          id: record.id,
          name: record.name,
          email: record.email,
          contact: record.mobile,
          role: record.role,
          is_active: record.active?,
          created_at: record.created_at.to_date.to_s
                  )
      end
      @export.update_attributes(status: 'Completed')
      generate_csv(@export)
    end
  end
  