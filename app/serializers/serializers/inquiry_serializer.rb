class Serializers::InquirySerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :created_at, :updated_at

  attribute :company_name do |inquiry|
    inquiry.company.name if inquiry.company.present?
  end

  attribute :contact_email do |inquiry|
    inquiry.contact.email if inquiry.contact.present?
  end

  attribute :contact_name do |inquiry|
    inquiry.contact.full_name if inquiry.contact.present?
  end

  attribute :created_by do |inquiry|
    inquiry.created_by.full_name if inquiry.created_by.present?
  end

  attribute :updated_by do |inquiry|
    inquiry.updated_by.full_name if inquiry.updated_by.present?
  end

  attribute :customer_po_number do |inquiry|
    inquiry.customer_po_number
  end

  attribute :customer_order_date do |inquiry|
    inquiry.customer_order_date
  end

  attribute :bill_from_warehouse do |inquiry|
     [inquiry.bill_from.name, inquiry.bill_from.address.to_s].join(" ") if inquiry.bill_from.present?
  end

  attribute :ship_from_warehouse do |inquiry|
    [inquiry.ship_from.name, inquiry.ship_from.address.to_s].join(" ") if inquiry.ship_from.present?
  end

  attribute :billing_address do |inquiry|
    [inquiry.bill_to_name, inquiry.billing_address.to_s].join(" ") if inquiry.billing_address.present?
  end

  attribute :shipping_address do |inquiry|
    #[inquiry.ship_to_name, inquiry.shipping_address.to_s].join(" ")
    inquiry.shipping_address.to_s if inquiry.shipping_address.present?
  end

  attribute :inside_sales_owner do |inquiry|
    inquiry.inside_sales_owner.full_name if inquiry.inside_sales_owner.present?
  end

  attribute :outside_sales_owner do |inquiry|
    inquiry.outside_sales_owner.full_name if inquiry.outside_sales_owner.present?
  end

  attribute :sales_manager do |inquiry|
    inquiry.sales_manager.full_name if inquiry.sales_manager.present?
  end

  attribute :payment_terms do |inquiry|
    inquiry.payment_option.name if inquiry.payment_option.present?
  end

  attribute :commercial_terms_and_conditions do |inquiry|
    inquiry.commercial_terms_and_conditions
  end

  # has_many :inquiry_products, :inverse_of => :inquiry
  # belongs_to :contact

  has_one :account, :through => :company, serializer: Serializers::AccountSerializer
  has_one :final_sales_quote, serializer: Serializers::SalesQuoteSerializer
  # has_many :sales_orders, :through => :final_sales_quote, serializer: Serializers::SalesOrderSerializer
  #has_many :sales_quote_rows, :through => :sales_orders

  # has_many :sales_quotes
  # has_many :sales_orders, :through => :sales_quotes

  #
  # class InquiryProductSerializer < ActiveModel::Serializer
  #   attributes :id, :quantity, :product
  #
  #   class ProductSerializer < ActiveModel::Serializer
  #     attributes :id, :brand_name
  #   end
  # end
  #
  # class ContactSerializer < ActiveModel::Serializer
  #   #to restrict the amount of fields needed
  #   attributes :first_name, :last_name, :email
  # end
  #
  # class SalesQuoteSerializer < ActiveModel::Serializer
  #   #to load sub fields related to the Model
  #   attributes :id, :company, :rows
  # end
end
