class PurchaseOrder < ApplicationRecord
  include Mixins::HasConvertedCalculations
  belongs_to :inquiry
  has_one :inquiry_currency, :through => :inquiry
  has_one :currency, :through => :inquiry_currency
  has_one :conversion_rate, :through => :inquiry_currency
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order
  has_one_attached :document

  update_index('purchase_orders#purchase_order') {self}
  #pg_search_scope :locate, :against => [], :associated_against => {:company => [:name], :inquiry => [:inquiry_number, :customer_po_number]}, :using => {:tsearch => {:prefix => true}}

  validates_with FileValidator, attachment: :document, file_size_in_megabytes: 2

  scope :with_includes, -> {includes(:inquiry)}

  def filename(include_extension: false)
    [
        ['po', po_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def get_supplier(product_id)
    product_supplier = self.inquiry.final_sales_quote.rows.select { | supplier_row |  supplier_row.product.id == product_id || supplier_row.product.legacy_id  == product_id}.first
    product_supplier.supplier if product_supplier.present?
  end

  def self.to_csv
    start_at = 'Fri, 19 Oct 2018'.to_date
    end_at = Date.today
    objects = [ ]
    self.where(:created_at => start_at..end_at).each do |po|
      inquiry = po.inquiry
      supplier = po.get_supplier(po.rows.first.metadata['PopProductId'].to_i)
      sales_orders = inquiry.sales_orders
      sales_order = nil
      if supplier.present?
        if sales_orders.present?
          sales_orders.each do |so|
            ids = [ ]
            if so.present?
              so.rows.each do |r|
                ids.push(r.sales_quote_row.inquiry_product_supplier.supplier.id)
              end
              if ids.include?(supplier.id)
                sales_order = so
              end
            end
          end
        end
      end
      po_number = po.po_number.to_s
      po_date = po.created_at.to_date.to_s
      inquiry_number = inquiry.inquiry_number.to_s
      inquiry_date = inquiry.created_at.to_date.to_s
      payment_terms = inquiry.payment_option.name if inquiry.payment_option.present?
      company_name = inquiry.company.name
      procurement_date = inquiry.procurement_date.to_date.to_s if inquiry.procurement_date.present?
      order_number = sales_order.order_number.to_s if sales_order.present?
      order_date = sales_order.created_at.to_date.to_s if sales_order.present?
      order_status = sales_order.status if sales_order.present?
      supplier_name = supplier.name if supplier.present?
      o = [po_number, po_date, inquiry_number, inquiry_date, payment_terms, company_name, procurement_date, order_number, order_date, order_status, supplier_name]
      objects.push(o)
    end
    desired_columns = ["po_number", "po_date", "inquiry_number", "inquiry_date", "payment_terms", "company_name", "procurement_date", "order_number", "order_date", "order_status", "supplier_name"]
    CSV.generate(write_headers: true, headers: desired_columns) do |csv|
      objects.each do |i|
        csv << i
      end
    end
  end
end
