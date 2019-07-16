class OutwardDispatch < ApplicationRecord
  include Mixins::CanBeStamped

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
      'Aramex': 1,
      'FedEx': 2,
      'Spoton': 3,
      'Safe Xpress': 4,
      'Professional Couriers': 5,
      'DTDC': 5,
      'Delhivery': 7,
      'UPS': 8,
      'Blue Dart': 9,
      'Anjani Courier': 10,
      'Mahavir Courier Services': 11,
      'Elite Enterprise': 12,
      'Sri Krishna Logistics': 13,
      'Maruti Courier': 14,
      'Vinod': 20,
      'Ganesh': 21,
      'Tushar': 22,
      'Others': 40,
      'Drop Ship': 60
  }

  def quantity_in_payment_slips
    self.packing_slips.sum(&:dispatched_quntity)
  end

  def status_auto_update
    if self.saved_change_to_material_delivery_date? && !material_delivery_date_before_last_save.present?
      self.status = 'Material Delivered'
      self.save
    end
  end

  def grouped_status
    grouped_status = {}
    status_category = { 1 => '3PL', 20 => 'BM Runner', 40 => 'Others', 60 => 'Drop Ship' }
    status_category.each do |index, category|
      grouped_status[category] = InwardDispatch.logistics_partners.collect { |status, v|
        if v.between?(index, index + 13)
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
