class Services::Overseers::Exporters::ImageReadersForDateExporter < Services::Overseers::Exporters::BaseExporter

  attr_accessor :param, :rows, :date, :start_at, :end_at, :model, :export_name, :path, :columns

  def initialize(param)
    @rows = []
    @date = param[:date]
    @start_at = @date.to_date.beginning_of_day
    @end_at = @date.to_date.end_of_day
    @model = ImageReader
    @export_name = 'image_readers'
    @path = Rails.root.join('tmp', filename)
    @columns = %w(image_name meter_number meter_reading status image_url created_at reference_id)
  end

  def call
    perform_export_later('ImageReadersForDateExporter')
  end

  def build_csv
    model.where(created_at: @start_at..@end_at).each do |record|
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
    export = Export.create!(export_type: 55)
    generate_csv(export)
  end
end