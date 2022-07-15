class Services::Overseers::Exporters::CategoriesExporter < Services::Overseers::Exporters::BaseExporter
    def initialize(*params)
      super(*params)
  
      @model = Category
      @export_name = 'categories'
      @path = Rails.root.join('tmp', filename)
      @columns = ['id','name', 'service','SAP_Status', 'active', 'created At' ]
    end
  
    def call
      perform_export_later('CategoriesExporter', @arguments)
    end
  
    def build_csv
      @export_time['creation'] = Time.now
      ExportMailer.export_notification_mail(@export_name,true,@export_time).deliver_now
      if @ids.present?
        records = model.where(id: @ids)
      else
        records = model
      end
      @export = Export.create!(export_type: 115, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
      records.all.order(created_at: :desc).find_each(batch_size: 100) do |record|
        rows.push(
          id: record.id,
          name: record.name,
          service: record.is_service,
          SAP_Synced: record.synced?,
          is_active: record.is_active,
          created_at: record.created_at.to_date.to_s
                  )
      end
      @export.update_attributes(status: 'Completed')
      generate_csv(@export)
    end
  end
  