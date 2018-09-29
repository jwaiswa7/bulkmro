class Serializers::InquirySerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :created_at, :updated_at

  attribute :company_name do |inquiry|
    inquiry.company.name
  end

  attribute :created_by do |inquiry|
    inquiry.created_by.full_name if inquiry.created_by.present?
  end

  attribute :updated_by do |inquiry|
    inquiry.updated_by.full_name if inquiry.updated_by.present?
  end

  # has_many :inquiry_products, :inverse_of => :inquiry
  # belongs_to :contact

  has_one :account, :through => :company, serializer: Serializers::AccountSerializer
  # has_one :final_sales_quote
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
