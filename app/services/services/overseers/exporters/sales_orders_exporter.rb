class Services::Overseers::Exporters::SalesOrdersExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = %w(
        Inquiry\ Number
        Order\ Number
        Order\ Date
        Company\ Name
        Company\ Alias
        Order\ Net\ Amount
        Order\ Tax\ Amount
        Order\ Total\ Amount
        Order\ Status
        Inside\ Sales
        Outside\ Sales
        Quote\ Type
        Opportunity\ Type
    )
    @model = SalesOrder
  end

  def call
    model.status_Approved.where(:created_at => start_at..end_at).each do |sales_order|
      inquiry = sales_order.inquiry
      
      rows.push({
                    :inquiry_number => inquiry.inquiry_number,
                    :order_number => sales_order.order_number,
                    :order_date => sales_order.created_at.to_date.to_s,
                    :company_alias => inquiry.account.name,
                    :company_name => inquiry.company.name,
                    :gt_exc => ('%.2f' % sales_order.calculated_total),
                    :tax_amount => ('%.2f' % sales_order.calculated_total_tax),
                    :gt_inc => ('%.2f' % sales_order.calculated_total_with_tax),
                    :status => sales_order.remote_status,
                    :inside_sales => sales_order.inside_sales_owner.to_s,
                    :outside_sales => sales_order.outside_sales_owner.to_s,
                    :quote_type => inquiry.quote_category,
                    :opportunity_type => inquiry.opportunity_type,
                })
    end

    generate_csv
  end
end