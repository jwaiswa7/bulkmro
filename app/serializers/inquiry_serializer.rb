class InquirySerializer < ActiveModel::Serializer
  attributes :inquiry_products, :company, :products, :shipping_address, :billing_address

  has_many :inquiry_products, :inverse_of => :inquiry

  belongs_to :contact
  belongs_to :company
  has_one :account, :through => :company
  has_many :sales_quotes
  has_many :sales_orders, :through => :sales_quotes

  class CompanySerializer < ActiveModel::Serializer
    #to restrict the amount of fields needed
    has_one :industry
    attributes :industry, :name

    class IndustrySerializer < ActiveModel::Serializer
      #to restrict the amount of fields needed
      attributes :name
    end
  end

  class InquiryProductSerializer < ActiveModel::Serializer

    attributes :id, :quantity, :product

    class ProductSerializer < ActiveModel::Serializer
      attributes :id, :brand_name
    end
  end

  class ContactSerializer < ActiveModel::Serializer
    #to restrict the amount of fields needed
    attributes :first_name, :last_name, :email
  end

  class SalesQuoteSerializer < ActiveModel::Serializer
    #to load sub fields related to the Model
    attributes :id, :company, :rows


  end
end
