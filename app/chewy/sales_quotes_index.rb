# frozen_string_literal: true

class SalesQuotesIndex < BaseIndex
  statuses = Inquiry.statuses
  define_type SalesQuote.limit(1).with_includes do
    witchcraft!
    field :id, type: "integer"
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i }, type: "integer"
    field :is_final, value: -> (record) { record.is_final? if record.id.present? }, type: "boolean"
    field :sent_at, type: "date"
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s }, analyzer: "substring"
    field :line_items, value: -> (record) { record.rows.size.to_s }, analyzer: "substring"
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: "substring"
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :valid_upto_s, value: -> (record) { record.inquiry.valid_end_time.to_s }, analyzer: "substring"
    field :status_string, value: -> (record) { record.inquiry.status.to_s }, analyzer: "substring"
    field :status, value: -> (record) { statuses[record.inquiry.status] }
    field :quote_total, value: -> (record) { record.calculated_total.to_i if record.calculated_total.present? }
    field :quote_total_string, value: -> (record) { record.calculated_total.to_s if record.calculated_total.present? }, analyzer: "substring"
    field :contact_id, value: -> (record) { record.inquiry.contact_id }, type: "integer"
    field :company_id, value: -> (record) { record.inquiry.company.id }, type: "integer"
    field :account_id, value: -> (record) { record.inquiry.account.id }, type: "integer"
    field :created_at, type: "date"
    field :inquiry_created_at, value: -> (record) { record.inquiry.created_at }, type: "date"
    field :cp_status_s, value: -> (record) { record.changed_status(record.inquiry.status).to_s }, analyzer: "substring"
    field :cp_valid_upto_s, value: -> (record) { record.inquiry.valid_end_time.strftime("%d-%b-%Y").to_s if record.inquiry.valid_end_time.present? }, analyzer: "substring"
    field :cp_created_at_s, value: -> (record) { record.created_at.strftime("%d-%b-%Y").to_s if record.created_at.present? }, analyzer: "substring"
    field :cp_po_number_s, value: -> (record) { record.inquiry.customer_po_number.to_s if record.inquiry.customer_po_number.present? }, analyzer: "substring"
    field :cp_calculated_total_s, value: -> (record) { record.calculated_total.to_s if record.calculated_total.present? }, analyzer: "substring"
    field :cp_quote_id_s, value: -> (record) { record.id.to_s if record.id.present? }, analyzer: "substring"
    field :cp_subject_s, value: -> (record) { record.inquiry.subject.to_s if record.inquiry.subject.present? }, analyzer: "substring"
    field :cp_company_s, value: -> (record) { record.inquiry.company.name.to_s if record.inquiry.company.name.present? }, analyzer: "substring"
    field :cp_contact_email_s, value: -> (record) { record.inquiry.contact.email.to_s if record.inquiry.contact.present? }, analyzer: "substring"
    field :cp_billing_city_s, value: -> (record) { record.inquiry.billing_address.city_name.to_s if record.inquiry.billing_address.present? }, analyzer: "substring"
    field :cp_shipping_city_s, value: -> (record) { record.inquiry.shipping_address.city_name.to_s if record.inquiry.shipping_address.present? }, analyzer: "substring"
    field :cp_billing_gst_s, value: -> (record) { [record.inquiry.billing_address.try(:gst) || record.inquiry.company.default_billing_address.try(:gst)].join if record.inquiry.billing_address.try(:gst) || record.inquiry.company.default_billing_address.try(:gst) }, analyzer: "substring"
    field :cp_shipping_gst_s, value: -> (record) { [record.inquiry.shipping_address.try(:gst) || record.inquiry.company.default_shipping_address.try(:gst)].join if record.inquiry.shipping_address.try(:gst) || record.inquiry.company.default_shipping_address.try(:gst) }, analyzer: "substring"
    field :sales_quote_rows do
      field :sku, value: -> (record, sales_quote_row) { sales_quote_row.product.sku if sales_quote_row.product.sku.present? }, analyzer: "substring"
      field :name, value: -> (record, sales_quote_row) { sales_quote_row.product.name if sales_quote_row.product.name.present? }, analyzer: "substring"
      field :brand, value: -> (record, sales_quote_row) { sales_quote_row.product.brand.name if sales_quote_row.product.brand.present? }, analyzer: "substring"
      field :mpn, value: -> (record, sales_quote_row) { sales_quote_row.product.mpn if sales_quote_row.product.mpn.present? }, analyzer: "substring"
    end
  end
end
