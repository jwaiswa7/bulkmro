

class SalesOrdersIndex < BaseIndex
  statuses = SalesOrder.statuses
  legacy_request_statuses = SalesOrder.legacy_request_statuses
  remote_statuses = SalesOrder.remote_statuses

  define_type SalesOrder.all.with_includes do
    witchcraft!
    field :id, type: "integer"
    field :order_number, value: -> (record) { record.order_number.to_s }, analyzer: "substring"
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i if record.inquiry.present? }, type: "integer"
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: "substring"
    field :status_string, value: -> (record) { record.status.to_s }, analyzer: "substring"
    field :status, value: -> (record) { statuses[record.status] }, type: "integer"
    field :legacy_request_status, value: -> (record) { legacy_request_statuses[record.legacy_request_status] }, type: "integer"
    field :approval_status, value: -> (record) { record.approved? ? "approved" : "pending" }
    field :remote_approval_status, value: -> (record) { record.remote_approved? ? "approved" : "pending" }
    field :legacy_status, value: -> (record) { record.legacy? ? "legacy" : "not_legacy" }
    field :remote_status_string, value: -> (record) { record.remote_status.to_s }, analyzer: "substring"
    field :remote_status, value: -> (record) { remote_statuses[record.remote_status] }, type: "integer"
    field :quote_total, value: -> (record) { record.sales_quote.calculated_total.to_i if record.sales_quote.present? && record.sales_quote.calculated_total.present? }
    field :order_total, value: -> (record) { record.calculated_total.to_i if record.rows.present? && record.calculated_total.present? }
    field :customer_po_number, value: -> (record) { record.inquiry.customer_po_number if record.inquiry.present? }
    field :customer_po_number_string, value: -> (record) { record.inquiry.customer_po_number.to_s if record.inquiry.present? }, analyzer: "substring"
    field :contact_id, value: -> (record) { record.inquiry.contact_id if record.inquiry.present? }, type: "integer"
    field :company_id, value: -> (record) { record.inquiry.company.id if record.inquiry.present? }, type: "integer"
    field :account_id, value: -> (record) { record.inquiry.contact.account.id if record.inquiry.present? }, type: "integer"
    field :account_name, value: -> (record) { record.inquiry.contact.account.name.to_s if record.inquiry.present? }, analyzer: "substring"
    field :company, value: -> (record) { record.inquiry.company.to_s if record.inquiry.present? }, analyzer: "substring"
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.present? && record.inquiry.inside_sales_owner.present? }
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s if record.inquiry.present? }, analyzer: "substring"
    field :outside_sales_owner_id, value: -> (record) { record.inquiry.outside_sales_owner.id if record.inquiry.present? && record.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s if record.inquiry.present? }, analyzer: "substring"
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id if record.inquiry.present? }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id if record.inquiry.present? }
    field :mis_date, value: -> (record) { record.mis_date }, type: "date"
    field :created_at, type: "date"
    field :updated_at, type: "date"
    field :sent_at, type: "date"
    field :created_by_id
    field :updated_by_id, value: -> (record) { record.updated_by.to_s }, analyzer: "substring"
    field :cp_status_s, value: -> (record) { record.effective_customer_status.to_s }, analyzer: "substring"
    field :cp_order_date_s, value: -> (record) { record.inquiry.customer_order_date.strftime("%d-%b-%Y").to_s if record.inquiry.customer_order_date.present? }, analyzer: "substring"
    field :cp_committed_date_s, value: -> (record) { record.inquiry.customer_committed_date.strftime("%d-%b-%Y").to_s if record.inquiry.customer_committed_date.present? }, analyzer: "substring"
    field :cp_created_at_s, value: -> (record) { record.created_at.strftime("%d-%b-%Y").to_s if record.created_at.present? }, analyzer: "substring"
    field :cp_calculated_total_s, value: -> (record) { record.calculated_total.to_s if record.calculated_total.present? }, analyzer: "substring"
    field :cp_quote_id_s, value: -> (record) { record.id.to_s if record.id.present? }, analyzer: "substring"
    field :cp_subject_s, value: -> (record) { record.inquiry.subject.to_s if record.inquiry.subject.present? }, analyzer: "substring"
    field :cp_ship_to_s, value: -> (record) { record.inquiry.shipping_contact.try(:name) || record.inquiry.billing_contact.try(:name) }, analyzer: "substring"
    field :cp_company_s, value: -> (record) { record.inquiry.company.name.to_s if record.inquiry.company.name.present? }, analyzer: "substring"
    field :cp_contact_email_s, value: -> (record) { record.inquiry.contact.email.to_s if record.inquiry.contact.email.present? }, analyzer: "substring"
    field :cp_billing_city_s, value: -> (record) { record.inquiry.billing_address.city_name.to_s if record.inquiry.billing_address.present? }, analyzer: "substring"
    field :cp_shipping_city_s, value: -> (record) { record.inquiry.shipping_address.city_name.to_s if record.inquiry.shipping_address.present? }, analyzer: "substring"
    field :cp_billing_gst_s, value: -> (record) { [record.inquiry.billing_address.try(:gst) || record.inquiry.company.default_billing_address.try(:gst)].join if record.inquiry.billing_address.try(:gst) || record.inquiry.company.default_billing_address.try(:gst) }, analyzer: "substring"
    field :cp_shipping_gst_s, value: -> (record) { [record.inquiry.shipping_address.try(:gst) || record.inquiry.company.default_shipping_address.try(:gst)].join if record.inquiry.shipping_address.try(:gst) || record.inquiry.company.default_shipping_address.try(:gst) }, analyzer: "substring"
    field :sales_order_rows do
      field :sku, value: -> (record, sales_order_row) { sales_order_row.sales_quote_row.product.remote_uid }, analyzer: "substring"
      field :brand, value: -> (record, sales_order_row) { sales_order_row.sales_quote_row.product.brand.name if sales_order_row.sales_quote_row.product.brand.present? }, analyzer: "substring"
      field :name, value: -> (record, sales_order_row) { sales_order_row.sales_quote_row.product.name if sales_order_row.sales_quote_row.product.name.present? }, analyzer: "substring"
      field :mpn, value: -> (record, sales_order_row) { sales_order_row.sales_quote_row.product.mpn if sales_order_row.sales_quote_row.product.mpn.present? }, analyzer: "substring"
    end
    field :invoice_total, type: "integer", value: -> (record) { record.invoice_total }
    field :order_total, type: "integer", value: -> (record) { record.order_total }
    field :potential_value, value: -> (record) { record.try(:calculated_total) }, type: "double"
  end
end
