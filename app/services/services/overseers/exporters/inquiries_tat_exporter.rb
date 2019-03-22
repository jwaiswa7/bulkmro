class Services::Overseers::Exporters::InquiriesTatExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = InquiryStatusRecord
    @start_at = Date.new(2019, 01, 01)
    @end_at = Date.today.end_of_day
    @export_name = 'inquiries'
    @path = Rails.root.join('tmp', filename)
    @columns = ["inquiry_number", "products", "status", "tat", "time", 'in Words', "Date Time", "TimeStamp"]
    @start_at = Date.new(2018, 04, 01)
  end

  def call
    perform_export_later('InquiriesExporter', @arguments)
  end

  def build_csv
    records = if @ids.present?
                model.includes(:inquiry).where.not(inquiry_id: nil).joins(:inquiry).where(id: @ids).order(created_at: :desc)
              else
                model.includes(:inquiry).where.not(inquiry_id: nil).joins(:inquiry).where(created_at: start_at..end_at).order(created_at: :desc)
              end

    records.each do |record|
      inquiry_number = inquiry_status.inquiry.inquiry_number  if inquiry_status.inquiry.present?

      products = inquiry_status.inquiry.products.count if inquiry_status.inquiry.present?

      status = inquiry_status.status

      tat = (inquiry_status.tat) / 60

      [inquiry_number, products, status, (tat / 60).ceil, Time.at(tat).utc.strftime("%H:%M:%S"), distance_of_time_in_words(tat), inquiry_status.created_at.strftime('%d-%b-%Y %H:%M'), inquiry_status.created_at.to_time.to_i]


      rows.push(
          inquiry_number: inquiry_number,
          order_number: products,
          status: status,
          tat_in_minutes: (tat / 60).ceil,
          tat_in_hms:  Time.at(tat).utc.strftime("%H:%M:%S"),
          tat_in_words:  distance_of_time_in_words(tat),
          status_generated_at: inquiry_status.created_at.strftime('%d-%b-%Y %H:%M'),
          status_time_stamp: inquiry_status.created_at.to_time.to_i,
      )
    end
    filtered = @ids.present?
    export = Export.create!(export_type: 1, filtered: filtered, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
