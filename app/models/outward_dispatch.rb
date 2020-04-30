class OutwardDispatch < ApplicationRecord
  COMMENTS_CLASS = 'OutwardDispatchComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  belongs_to :ar_invoice_request, default: false
  belongs_to :sales_invoice, default: false
  belongs_to :sales_order, default: false
  has_many :packing_slips
  accepts_nested_attributes_for :packing_slips, reject_if: lambda { |attributes| attributes['box_number'].blank? }, allow_destroy: true
  has_many :email_messages
  after_save :status_auto_update
  scope :with_includes, -> { }
  update_index('outward_dispatches#outward_dispatch') {self}

  enum status: {
      'Material Ready for Dispatch': 10,
      'Material Dispatched': 20,
      # 'Dispatch Approval Pending': 20,
      # 'Dispatch Rejected': 30,
      #
      # 'Material In Transit': 40,
      # 'Material Delivered Pending GRN': 50,
      'Material Delivered': 60
  }

  enum logistics_partner: {
      'ACPL': 1,
      'ARC Transport': 2,
      'Anjani Courier': 3,
      'Aramex': 4,
      'Arunah Transport': 5,
      'Blue Dart': 6,
      'DTDC': 7,
      'Delhivery': 8,
      'Elite Enterprise': 9,
      'FedEx': 10,
      'Gati': 11,
      'Mahavir Courier Services': 12,
      'Maruti Courier': 13,
      'Professional Couriers': 14,
      'Safe Xpress': 15,
      'Spoton': 16,
      'Sri Krishna Logistics': 17,
      'TCI Freight': 18,
      'TCI Xpress': 19,
      'Trackon': 20,
      'UPS': 21,
      'V Trans': 22,
      'VRL Logistics': 23,
      'Vinod': 100,
      'Ganesh': 101,
      'Tushar': 102,
      'Others': 200,
      'Drop Ship': 300
  }

  def quantity_in_payment_slips
    self.packing_slips.sum(&:dispatched_quantity)
  end

  def status_auto_update
    if self.saved_change_to_material_delivery_date? && !material_delivery_date_before_last_save.present?
      self.status = 'Material Delivered'
      self.save
    elsif self.saved_change_to_material_delivery_date? && material_delivery_date_before_last_save.present? && !self.material_delivery_date.present?
      self.status = 'Material Ready for Dispatch'
      self.save
    end
  end

  def grouped_logistics_partners
    grouped_logistics_partners = {}
    status_category = { 1 => '3PL', 100 => 'BM Runner', 200 => 'Others', 300 => 'Drop Ship' }
    status_category.each do |index, category|
      grouped_logistics_partners[category] = OutwardDispatch.logistics_partners.collect { |status, v|
        if v.between?(index, index + 98)
          status
        end}.compact
    end
    grouped_logistics_partners
  end

  def is_owner
    self.sales_invoice.inquiry.inside_sales_owner.to_s
  end

  def logistics_owner
    self.sales_invoice.inquiry.company.logistics_owner.full_name if self.sales_invoice.inquiry.present? && self.sales_invoice.inquiry.company.present? &&
        self.sales_invoice.inquiry.company.logistics_owner.present?
  end

  def zipped_filename(include_extension: false)
    [
        ['packing_slips', self.sales_invoice.invoice_number].join('_'),
        ('zip' if include_extension)
    ].compact.join('.')
  end
end
