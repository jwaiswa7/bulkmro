class Services::Overseers::Exporters::ImageReadersForDateExporter < Services::Overseers::Exporters::BaseExporter

  attr_accessor :param, :rows, :date, :start_at, :end_at, :model, :export_name, :path, :columns

  def initialize(params)
    @rows = []
    @date = params[:date]
    @status = params[:status]
    @start_at = @date.to_date.beginning_of_day
    @end_at = @date.to_date.end_of_day
    @model = ImageReader
    @path = Rails.root.join('tmp', filename)
    @columns = %w(image_name meter_number meter_reading status image_url created_at reference_id)
    @columns.each do |column|
      rows.push(column)
    end
  end

  def call
    build_csv
  end

  def build_csv
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(rows)
      model.where("created_at >= :start_at AND created_at <= :end_at AND status = :status", {start_at: @start_at, end_at: @end_at, status: ImageReader.statuses[@status]}).each do |record|
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
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end