class CustomerProduct < ApplicationRecord

  include ActiveModel::Validations

  belongs_to :brand, required: false
  belongs_to :category, required: false
  belongs_to :company, required: false
  belongs_to :product, required: false

  has_many_attached :images

  validates_presence_of :name
  validates_presence_of :sku
  validates_numericality_of :unit_selling_price, greater_than: 0.00
  validates :company_id, uniqueness: {scope: :sku}

  after_initialize :set_unit_selling_price

  def set_unit_selling_price
    self.unit_selling_price ||= price!
  end

  def price!
    Rails.cache.fetch("#{self.class}-#{self.to_param}/price", expires_in: 12.hours) do
      if self.customer_price.present?
        self.customer_price
      else
        company_inquiries = Inquiry.includes(:sales_quote_rows, :sales_order_rows).where(company_id: self.company_id)
        sales_order_rows = company_inquiries.map {|i| i.sales_order_rows.joins(:product).where('products.id = ?', self.product_id)}.flatten.compact
        sales_order_row_price = sales_order_rows.map {|r| r.unit_selling_price}.flatten if sales_order_rows.present?
        if sales_order_row_price.present?
          sales_order_row_price.min
        else
          sales_quote_rows = company_inquiries.map {|i| i.sales_quote_rows.joins(:product).where('products.id = ?', self.product_id)}.flatten.compact
          sales_quote_row_price = sales_quote_rows.pluck(:unit_selling_price)
          sales_quote_row_price.min
        end
      end
    end
  end

end
