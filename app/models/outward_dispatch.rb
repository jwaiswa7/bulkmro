class OutwardDispatch < ApplicationRecord
  COMMENTS_CLASS = 'OutwardDispatchComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  belongs_to :ar_invoice_request, default: false
  belongs_to :sales_order, default: false
  has_many :packing_slips
  has_many :email_messages
  after_save :status_auto_update
  scope :with_includes, -> { }
  update_index('outward_dispatches#outward_dispatch') {self}

  enum status: {
      'Material Ready for Dispatch': 10,
      # 'Dispatch Approval Pending': 20,
      # 'Dispatch Rejected': 30,
      # 'Material In Transit': 40,
      # 'Material Delivered Pending GRN': 50,
      'Material Delivered': 60
  }

  enum logistics_partners: {
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

  def grouped_status
    grouped_status = {}
    status_category = { 1 => '3PL', 100 => 'BM Runner', 200 => 'Others', 300 => 'Drop Ship' }
    status_category.each do |index, category|
      grouped_status[category] = OutwardDispatch.logistics_partners.collect { |status, v|
        if v.between?(index, index + 99)
          status
        end}.compact
    end
    grouped_status
  end

  def is_owner
    self.ar_invoice_request.inquiry.inside_sales_owner.to_s
  end

  def logistics_owner
    self.ar_invoice_request.inquiry.company.logistics_owner.full_name if self.ar_invoice_request.inquiry.present? && self.ar_invoice_request.inquiry.company.present? && self.ar_invoice_request.inquiry.company.logistics_owner.present?
  end
end
