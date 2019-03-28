class Services::Overseers::Exporters::InquiriesTatExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Inquiry
    @start_at = Date.new(2019, 01, 01)
    @end_at = Date.new(2019, 02, 01)
    # @end_at = Date.today.end_of_day
    @export_name = 'inquiries_tat'
    @path = Rails.root.join('tmp', filename)
    @columns = ['Inquiry Number', 'Inquiry Created Time', 'Products', 'Inside Sales Owner', 'Sales Quote', 'SO Doc ID', 'Sales Order Number', 'Sales Order Status', 'New Inquiry', 'Acknowledgement Mail', 'Cross Reference', 'Preparing Quotation', 'Quotation Sent', 'Draft SO for Approval by Sales Manager', 'SO Rejected by Sales Manager', 'SO Draft: Pending Accounts Approval', 'Rejected by Accounts', 'Hold by Accounts', 'Order Won', 'Order Lost', 'Regret', 'SAP Rejected']
  end

  def call
    perform_export_later('InquiriesTatExporter', @arguments)
  end

  def build_csv
    inquiries = model.where(created_at: start_at..end_at).order(created_at: :asc)
    @rows = []
    inquiries.each do |inquiry|
      products = inquiry.products.count if inquiry.present?
      inquiry_status_record = InquiryStatusRecord.where(subject_id: inquiry.id, subject_type: 'Inquiry').last
      if inquiry.sales_orders.present?

        inquiry.sales_orders.each do |sales_order|
          row = {'Inquiry Number' => inquiry.inquiry_number, 'Inquiry Created Time' => inquiry.created_at.to_date.to_s, 'Products' => products, 'Inside Sales Owner' => inquiry.inside_sales_owner.to_s, 'Sales Quote' => '-', 'SO Doc ID' => '-', 'Sales Order Number' => '-', 'Sales Order Status' => '-', 'New Inquiry' => '0', 'Acknowledgement Mail' => '-', 'Cross Reference' => '-',  'Preparing Quotation' => '-', 'Quotation Sent' => '-', 'Draft SO for Approval by Sales Manager' => '-', 'SO Rejected by Sales Manager' => '-', 'SO Draft: Pending Accounts Approval' => '-', 'Rejected by Accounts' => '-', 'Hold by Accounts' => '-', 'Order Won' => '-', 'Order Lost' => '-', 'Regret' => '-'}
          status_record = InquiryStatusRecord.where(subject_id: sales_order.id, subject_type: 'SalesOrder').first
          if status_record.present?
            row['SO Doc ID'] = sales_order.id
            row['Sales Quote'] = sales_order.sales_quote.id
            row['Sales Order Number'] = sales_order.order_number
            row['Sales Order Status'] = sales_order.status
            @rows << fill_row(row, latest_status_record('SalesOrder', sales_order))
          elsif inquiry.sales_quotes.present?
            inquiry.sales_quotes.each do |sales_quote|
              status_record = InquiryStatusRecord.where(subject_id: sales_quote.id, subject_type: 'SalesQuote').first
              if status_record.present? && sales_quote.sales_orders.blank?
                row['Sales Quote'] = sales_quote.id
                @rows << fill_row(row, latest_status_record('SalesQuote', sales_quote))
              end
            end
          elsif inquiry_status_record.present?
            @rows << fill_row(row, latest_status_record('Inquiry', inquiry))
          end
        end
      elsif inquiry.final_sales_quote.present?
        sales_quote = inquiry.final_sales_quote
        # inquiry.sales_quotes.each do |sales_quote|
        row = {'Inquiry Number' => inquiry.inquiry_number, 'Inquiry Created Time' => inquiry.created_at.to_date.to_s, 'Products' => products, 'Inside Sales Owner' => inquiry.inside_sales_owner.to_s, 'Sales Quote' => '-', 'SO Doc ID' => '-', 'Sales Order Number' => '-', 'Sales Order Status' => '-', 'New Inquiry' => '0', 'Acknowledgement Mail' => '-', 'Cross Reference' => '-',  'Preparing Quotation' => '-', 'Quotation Sent' => '-', 'Draft SO for Approval by Sales Manager' => '-', 'SO Rejected by Sales Manager' => '-', 'SO Draft: Pending Accounts Approval' => '-', 'Rejected by Accounts' => '-', 'Hold by Accounts' => '-', 'Order Won' => '-', 'Order Lost' => '-', 'Regret' => '-'}
        status_record = InquiryStatusRecord.where(subject_id: sales_quote.id, subject_type: 'SalesQuote').first
        if status_record.present? && sales_quote.sales_orders.blank?
          row['Sales Quote'] = sales_quote.id
          @rows << fill_row(row, latest_status_record('SalesQuote', sales_quote))
        end
        # end
      elsif inquiry_status_record.present?
        row = {'Inquiry Number' => inquiry.inquiry_number, 'Inquiry Created Time' => inquiry.created_at.to_date.to_s, 'Products' => products, 'Inside Sales Owner' => inquiry.inside_sales_owner.to_s, 'Sales Quote' => '-', 'SO Doc ID' => '-', 'Sales Order Number' => '-', 'Sales Order Status' => '-', 'New Inquiry' => '0', 'Acknowledgement Mail' => '-', 'Cross Reference' => '-',  'Preparing Quotation' => '-', 'Quotation Sent' => '-', 'Draft SO for Approval by Sales Manager' => '-', 'SO Rejected by Sales Manager' => '-', 'SO Draft: Pending Accounts Approval' => '-', 'Rejected by Accounts' => '-', 'Hold by Accounts' => '-', 'Order Won' => '-', 'Order Lost' => '-', 'Regret' => '-'}
        @rows << fill_row(row, latest_status_record('Inquiry', inquiry))
      end
    end
    filtered = @ids.present?
    export = Export.create!(export_type: 2, filtered: filtered, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end


  def latest_status_record(subject, record)
    InquiryStatusRecord.not_expected_order.where(subject_id: record.id, subject_type: subject).latest.first
  end

  def fill_row(row, record)
    previous_record = record&.previous_status_record
    row[record.status] = "#{record.tat}" if record.present?
    row = fill_row(row, previous_record) if previous_record.present?
    row
  end
end
