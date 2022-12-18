class Services::Overseers::Exporters::AddressesExporter < Services::Overseers::Exporters::BaseExporter
    def initialize(*params)
      super(*params)

      @model = Address
      @export_name = 'addresses'
      @path = Rails.root.join('tmp', filename)
      @columns = ['id','company_name', 'address','state','city', 'is_valid_gst', 'gst_number' , 'pin_code']
    end

    def call
      perform_export_later('AddressesExporter', @arguments)
    end

    def build_csv
      @export_time['creation'] = Time.now
      ExportMailer.export_notification_mail(@export_name,true,@export_time).deliver_now
      if @ids.present?
        records = model.where(id: @ids)
      else
        records = model
      end
      @export = Export.create!(export_type: 125, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
      records.has_company_id.order(created_at: :desc).find_each(batch_size: 100) do |record|
        rows.push(
          id: record.id,
          company_name: record.company.to_s,
          address: record.to_s,
          state: record.try(:state).try(:name),
          city: record.try(:city_name),
          is_valid_gst: record.validate_gst, 
          gst_number: record.readable_gst,
          pin_code: record.try(:pincode)
                  )
      end
      @export.update_attributes(status: 'Completed')
      generate_csv(@export)
    end
  end