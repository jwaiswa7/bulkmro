class Services::Overseers::Exporters::ImageReadersExporter < Services::Overseers::Exporters::BaseExporter
  def initialize
    super
    @model = ImageReader
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
      model.all.order(created_at: :desc).each do |record|
        rows.push(
          image_name: record.image_name,
          meter_number: record.meter_number,
          meter_reading: record.meter_reading,
          status: record.status,
          image_url: record.image_url,
          created_at: record.created_at.to_date.to_s,
          reference_id: record.reference_id
                  )
      end
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
