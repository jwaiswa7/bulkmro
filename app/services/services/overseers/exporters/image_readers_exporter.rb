class Services::Overseers::Exporters::ImageReadersExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super
    @model = ImageReader
    @export_name = 'image_readers'
    @path = Rails.root.join('tmp', filename)
    @columns = %w(image_name meter_number meter_reading status image_url created_at reference_id)
  end

  def call
    perform_later()
  end

  def call_later
    build_csv
  end

  def build_csv
    model.all.order(created_at: :desc).each do |record|
      rows.push({
                    :image_name => record.image_name,
                    :meter_number => record.meter_number,
                    :meter_reading => record.meter_reading,
                    :status => record.status,
                    :image_url => record.image_url,
                    :created_at => record.created_at.to_date.to_s,
                    :reference_id => record.reference_id
                })
    end
    export = Export.create!(export_type: 50)
    generate_csv(export)
  end
end