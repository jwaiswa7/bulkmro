class SalesQuote < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSent
  include Mixins::CanBeSynced
  include Mixins::HasConvertedCalculations

  has_closure_tree({name_column: :to_s})

  update_index('sales_quotes#sales_quote') {self}
  belongs_to :inquiry
  has_many :comments, -> {where(:show_to_customer => true)}, :through => :inquiry
  accepts_nested_attributes_for :comments
  has_one :inquiry_currency, :through => :inquiry
  has_one :freight_request
  accepts_nested_attributes_for :inquiry_currency
  has_one :currency, :through => :inquiry_currency
  has_one :conversion_rate, :through => :inquiry_currency
  has_one :company, :through => :inquiry
  has_many :inquiry_products, :through => :inquiry
  has_many :rows, -> {joins(:inquiry_product).order('inquiry_products.sr_no ASC')}, class_name: 'SalesQuoteRow', inverse_of: :sales_quote, dependent: :destroy
  accepts_nested_attributes_for :rows, reject_if: lambda {|attributes| attributes['inquiry_product_supplier_id'].blank? && attributes['id'].blank?}, allow_destroy: true
  has_many :sales_quote_rows, inverse_of: :sales_quote
  has_many :products, :through => :rows
  has_many :sales_orders, dependent: :destroy
  has_many :unique_products, -> {uniq}, through: :rows, class_name: 'Product'
  has_many :email_messages, dependent: :destroy

  delegate :ship_from, :bill_from, :billing_address, :shipping_address, :is_sez, :quotation_uid, to: :inquiry

  scope :with_includes, -> {includes(:created_by, :updated_by, :parent, :inquiry)}

  attr_accessor :selected_suppliers

  #validates_length_of :rows, minimum: 1, :message => "must have at least one sales quote row"
  validates_presence_of :parent_id, :if => :inquiry_has_many_sales_quotes?
  # validate :every_product_only_has_one_supplier?
  # def every_product_only_has_one_supplier?
  #   self.rows.joins(:inquiry_product).group('inquiry_products.id').count.each do |k, v|
  #     if v > 1
  #       errors.add :base, 'every inquiry product can only have one designated supplier'
  #     end
  #   end
  # end
  #

  after_save :handle_smart_queue

  def handle_smart_queue
    self.inquiry.update_attributes(calculated_total: calculated_total)
    service = Services::Overseers::Inquiries::HandleSmartQueue.new(self.inquiry)
    service.call
  end

  def syncable_identifiers
    [:quotation_uid]
  end

  def inquiry_has_many_sales_quotes?
    self.inquiry.sales_quotes.except_object(self).count >= 1
  end

  def tax_summary
    self.rows.first.taxation.to_s
  end

  def sales_quote_quantity_not_fulfilled?
    self.calculated_total_quantity > self.sales_orders.remote_approved.persisted.map {|sales_order| sales_order.calculated_total_quantity }.compact.sum
  end

  def filename(include_extension: false)
    [
        [
            'quotation', inquiry.inquiry_number
        ].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def changed_status(status)
    if status == 'New Inquiry' || status == 'Acknowledgement Mail'
      'Inquiry Sent'
    elsif status == 'Cross Reference' || status == 'Preparing Quotation' || status == 'Supplier RFQ Sent'
      'Preparing Quotation'
    elsif status == 'Quotation Sent' || status == 'Follow Up on Quotation' || status == 'Expected Order'
      'Quotation Received'
    elsif status == 'SO Draft: Pending Accounts Approval' || status == 'SO Rejected by Sales Manager' || status == 'Order Won' || status == 'Draft SO for Approval by Sales Manager'
      'Purchase Order Issued'
    elsif status == 'SO Not Created-Pending Customer PO Revision' || status == 'SO Not Created-Customer PO Awaited'
      'Purchase Order Revision Pending'
    elsif status == 'Regret' || status == 'Order Lost'
      'Closed'
    end
  end

  def to_s
    ['#', inquiry.inquiry_number].join
  end

  def is_final?
    if self.id.present? && self.inquiry.final_sales_quote == self
      true
    elsif self.sales_orders.size >= 1
      true
    else
      false
    end
  end
end