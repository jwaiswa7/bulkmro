class Serializers::InquirySerializer < Serializers::BaseSerializer
  attributes :billing_address, :shipping_address, :customer_po_number, :customer_order_date, :commercial_terms_and_conditions, :is_sez
  attributes :bill_from, :ship_from, :billing_address, :shipping_address
  attributes :payment_option
  attributes :inquiry_products
  attributes :inside_sales_owner, :outside_sales_owner, :sales_manager
  attributes :account, :contact
  attributes :company_id, :shipping_company_id
  attributes :sales_quotes
  attributes :sales_quote_rows
  attributes :sales_orders
  attributes :sales_order_rows
  attributes :created_by, :updated_by
end
