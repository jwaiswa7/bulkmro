class Services::Overseers::Exporters::SalesOrdersLogisticsExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = ['order_number', 'order_date', 'quote_number', 'quote_type', 'opportunity_type', 'invoice_number', 'inside_sales', 'outside_sales', 'company_alias', 'company_name', 'bill_to_name', 'ship_to_name', 'customer_po_number', 'grand_total (Exc. Tax)', 'grand_total (Inc.Tax)', 'buying_cost (Exc. Tax)', 'margin (Exc. tax)', 'status', 'customer_committed_date']
    @model = SalesOrder
  end

  def call
    model.status_Approved.where(:created_at => start_at..end_at).each do |sales_order|
      inquiry = sales_order.inquiry

      rows.push({
                    :order_number => sales_order.order_number,
                    :order_date => sales_order.created_at.to_date.to_s,
                    :quote_number => inquiry.inquiry_number,
                    :quote_type => inquiry.quote_category,
                    :opportunity_type => inquiry.opportunity_type,
                    :invoice_number => sales_order.invoices.pluck(:invoice_number).join(","),
                    :inside_sales => sales_order.inside_sales_owner.to_s,
                    :outside_sales => sales_order.outside_sales_owner.to_s,
                    :company_alias => inquiry.account.name,
                    :company_name => inquiry.company.name,
                    :bill_to_name => inquiry.contact.full_name,
                    :ship_to_name => inquiry.contact.full_name,
                    :customer_po_number => inquiry.customer_po_number,
                    :gt_exc => ('%.2f' % sales_order.calculated_total),
                    :gt_inc => ('%.2f' % sales_order.calculated_total_with_tax),
                    :buying_cost_exc => ('%.2f' % sales_order.calculated_total_cost),
                    :margin_exc => ('%.2f' % sales_order.calculated_total_margin),
                    :status => sales_order.remote_status,
                    :customer_committed_date => ( inquiry.customer_committed_date.present? ? inquiry.customer_committed_date.to_date.to_s : nil ),
                })
    end

    generate_csv
  end
end
