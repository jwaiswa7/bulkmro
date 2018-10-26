class PurchaseOrder < ApplicationRecord
  include Mixins::HasConvertedCalculations
  update_index('purchase_orders#purchase_order') {self}

  belongs_to :inquiry
  has_one :inquiry_currency, :through => :inquiry
  has_one :currency, :through => :inquiry_currency
  has_one :conversion_rate, :through => :inquiry_currency
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order
  has_one_attached :document

  validates_with FileValidator, attachment: :document, file_size_in_megabytes: 2

  scope :with_includes, -> {includes(:inquiry)}

  def filename(include_extension: false)
    [
        ['po', po_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def self.to_csv
    start_at = Date.today - 2.day
    end_at = Date.today
    desired_columns = %w{po_number po_date inquiry_number inquiry_date payment_terms company_name procurement_date order_number order_date order_status supplier_name}
    array_of_objects = [ ]
    self.where(:created_at => start_at..end_at).each do |po|
      inquiry = po.inquiry
      supplier = get_supplier(po, po.rows.first.metadata['PopProductId'].to_i)
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
              sales_order = so if ids.include?(supplier.id)
            end
          end
        end
      end
      order_number = sales_order.order_number.to_s if sales_order.present?
      order_date = sales_order.created_at.to_date.to_s if sales_order.present?
      order_status = sales_order.status if sales_order.present?
      supplier_name = supplier.name if supplier.present?
      array_of_objects.push([po.po_number.to_s, po.created_at.to_date.to_s, inquiry.inquiry_number.to_s, inquiry.created_at.to_date.to_s, (inquiry.payment_option.name if inquiry.payment_option.present?), inquiry.company.name, (inquiry.procurement_date.to_date.to_s if inquiry.procurement_date.present?), order_number, order_date, order_status, supplier_name])
    end

    CSV.generate(write_headers: true, headers: desired_columns) do |csv|
      array_of_objects.each do |i|
        writer << i
      end
    end
  end
end
