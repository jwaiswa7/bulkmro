class SalesQuote < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSent
  include Mixins::CanBeSynced
  include Mixins::HasRowCalculations

  has_closure_tree({ name_column: :to_s })

  belongs_to :inquiry
  has_one :inquiry_currency, :through => :inquiry
  accepts_nested_attributes_for :inquiry_currency

  has_one :currency, :through => :inquiry_currency
  has_one :company, :through => :inquiry
  has_many :inquiry_products, :through => :inquiry
  has_many :rows, -> { joins(:inquiry_product).order('inquiry_products.sr_no ASC') }, class_name: 'SalesQuoteRow', inverse_of: :sales_quote, dependent: :destroy
  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| attributes['inquiry_product_supplier_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  has_many :products, :through => :rows
  has_many :sales_orders
  has_many :unique_products, -> { uniq }, through: :rows, class_name: 'Product'

  attr_accessor :selected_suppliers

  validates_length_of :rows, minimum: 1
  validates_presence_of :parent_id, :if => :inquiry_has_many_sales_quotes?
  validate :every_product_only_has_one_supplier?
  def every_product_only_has_one_supplier?
    self.rows.joins(:inquiry_product).group('inquiry_products.id').count.each do |k, v|
      if v > 1
        errors.add :base, 'every inquiry product can only have one designated supplier'
      end
    end
  end

  def syncable_identifiers
    [:quotation_uid]
  end

  def inquiry_has_many_sales_quotes?
    self.inquiry.sales_quotes.except_object(self).count >= 1
  end
end