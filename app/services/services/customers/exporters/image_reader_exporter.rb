class Services::Customers::Exporters::ImageReadersExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super
    @model = ImageReader
    @export_name = 'image_readers'
    @path = Rails.root.join('tmp', filename)
    @columns = ['image_name', 'meter_number', 'meter_reading', 'status', 'image_url', 'created_at']
  end

  def call
    perform_export_later('ImageReaderExporter')
  end

  def build_csv
    model.all.group_by{ |s| s.created_at }.each do |record|
      rows.push({
                    :image_name => record.image_name,
                    :meter_number => record.meter_number,
                    :meter_reading => record.meter_reading,
                    :status => record.status,
                    :image_url => record.image_url,
                    :created_at => record.created_at.to_date.to_s
                })
    end
    export = Export.create!(export_type: 10)
    generate_csv(export)
  end
end