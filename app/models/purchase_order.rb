class PurchaseOrder < ApplicationRecord
  belongs_to :inquiry
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order
  has_one_attached :document
  include Mixins::HasRowCalculations

  update_index('purchase_orders#purchase_order') {self}
  #pg_search_scope :locate, :against => [], :associated_against => {:company => [:name], :inquiry => [:inquiry_number, :customer_po_number]}, :using => {:tsearch => {:prefix => true}}
  has_closure_tree({name_column: :to_s})

  validates_with FileValidator, attachment: :document, file_size_in_megabytes: 2

  scope :with_includes, -> {includes(:inquiry)}

  def filename(include_extension: false)
    [
        ['po', po_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def self.to_csv
    start_at = Date.today - 5.day
    end_at = Date.today
    desired_columns = %w{id po_number inquiry_number inquiry_date procurement_date sales_order_number order_status payment_terms}
    CSV.generate(write_headers: true, headers: desired_columns) do |csv|
      where(:created_at => start_at..end_at).map{|po| [po.id.to_s, po.po_number.to_s, po.inquiry.inquiry_number.to_s, po.inquiry.created_at.to_date.to_s, (po.inquiry.procurement_date.to_date.to_s if po.inquiry.procurement_date.present?), (po.inquiry.final_sales_orders.first.order_number if po.inquiry.final_sales_orders.present?), (po.inquiry.final_sales_orders.first.remote_status if po.inquiry.final_sales_orders.present?), (po.inquiry.payment_option.name if po.inquiry.payment_option.present?)] }.each do |p_o|
        csv << p_o
      end
    end
  end
end
