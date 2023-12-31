class InvoiceRequest < ApplicationRecord
  COMMENTS_CLASS = 'InvoiceRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments
  update_index('inward_dispatches') { self.inward_dispatches }
  update_index('invoice_requests') { self }

  pg_search_scope :locate, against: [:id, :grpo_number, :ap_invoice_number, :ar_invoice_number], associated_against: { sales_order: [:id, :order_number], inquiry: [:inquiry_number] }, using: { tsearch: { prefix: true } }

  belongs_to :sales_order, required: false
  belongs_to :inquiry
  belongs_to :purchase_order, required: false
  has_many :inward_dispatches
  has_many_attached :attachments
  has_many :company_reviews, as: :rateable
  belongs_to :sales_invoice, required: false
  ratyrate_rateable 'CompanyReview'

  after_save :send_notification_on_status_changed

  enum status: {
      'GRPO Pending': 10,
      'Pending AP Invoice': 20,
      'Pending AR Invoice': 30,
      'In stock': 70,
      'Completed AR Invoice Request': 40,
      'Cancelled AR Invoice': 50,
      'Cancelled': 60,
      'AP Invoice Request Rejected': 80,
      'GRPO Request Rejected': 90,
      'Inward Completed': 110,
      'Cancelled AP Invoice': 120,
      'Cancelled GRPO': 130
  }

  enum main_summary_status: {
      'GRPO Pending': 10,
      'Pending AR Invoice': 30,
      'In stock': 70,
      'Inward Completed': 110
  }, _suffix: true

  enum grpo_rejection_reason: {
      'Mismatch: Supplier PO vs Supplier Invoice': 10,
      'Mismatch: HSN / SAC Code': 20,
      'Mismatch: Tax Rates': 30,
      'Mismatch: Supplier Billing or Shipping Address': 40,
      'Mismatch: Supplier GST Number': 50,
      'Mismatch: Supplier Name': 60,
      'Mismatch: Quantity': 70,
      'Mismatch: Unit Price': 80,
      'Mismatch: SKU / Description': 90,
      'Others': 100
  }

  scope :with_includes, -> { includes(:created_by, :updated_by, :inquiry) }
  scope :grpo_pending, -> { where(status: :'GRPO Pending') }
  scope :ap_invoice_pending, -> { where(status: :'Pending AP Invoice') }
  scope :ar_invoice_pending, -> { where(status: :'Pending AR Invoice') }
  scope :ar_invoice_generated, -> { where(status: :'Completed AR Invoice Request') }

  validates_presence_of :sales_order, if: Proc.new { |invoice_request| invoice_request.purchase_order.po_request.po_request_type != 'Stock' if invoice_request.purchase_order.po_request.present? }
  validates_presence_of :inquiry
  validates_numericality_of :ap_invoice_number, allow_blank: true
  validate :has_attachments?
  validate :grpo_number_valid?, unless: :skip_grpo_number_validation
  validate :presence_of_reason
  validate :valid_inward_dispatches?

  attr_accessor :skip_grpo_number_validation

  def grpo_number_valid?
    if self.created_date.present? && self.created_date < '2019-04-01' && self.grpo_number.present? && self.grpo_number <= 50000000
      errors.add(:grpo_number, 'must be 8 digits starting with 5')
    elsif (self.created_date.blank? || (self.created_date.present? && self.created_date > '2019-04-01')) && self.grpo_number.present? && self.grpo_number <= 200000000
      errors.add(:grpo_number, 'must be 9 digits starting with 2')
    end
  end


  def has_attachments?
    if !['Cancelled GRPO', 'Cancelled AP Invoice'].include?(self.status)
      if  !self.attachments.any?
        errors.add(:attachments, "must be present to create or update a #{self.readable_status}")
      end
    end
  end

  def valid_inward_dispatches?
    error_array = []
    self.inward_dispatches.each do |inward_dispatch|
      if !inward_dispatch.valid?
        error_array << inward_dispatch.errors.full_messages
      end
    end
    if !error_array.empty?
      errors.add(:inward_dispatches, error_array.uniq.join(', '))
    end
  end

  validate :shipment_number_valid?

  def shipment_number_valid?
    if self.shipment_number.present? && self.shipment_number <= 30000000
      errors.add(:shipment_number, 'must be 8 digits starting with 3')
    end
  end

  with_options if: :"Pending AP Invoice?" do |invoice_request|
    invoice_request.validates_presence_of :grpo_number
  end


  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.status ||= :'GRPO Pending'
  end

  def update_status(status)
    if ['In stock', 'Cancelled GRPO', 'GRPO Request Rejected', 'AP Invoice Request Rejected', 'Cancelled AP Invoice'].include? (status)
      self.status = status
    elsif self.ar_invoice_number.present?
      self.status = :'Completed AR Invoice Request'
    elsif self.ap_invoice_number.present?
      # self.status = :'Pending AR Invoice'
      self.status = :'Inward Completed'
    elsif self.grpo_number.present?
      self.status = :'Pending AP Invoice'
    else
      self.status = status
    end
  end

  def readable_status
    status = self.status
    if status.include? 'Pending'
      title_without_pending = status.remove('Pending')
      title = status.include?('GRPO') ? 'GRPO' : "#{title_without_pending}"
    elsif (status.include? 'Completed AR Invoice') || (status.include? 'Cancelled AR Invoice')
      title = status.gsub(status, 'AR Invoice')
    elsif status.include? 'Cancelled AP Invoice'
      title = status.gsub(status, 'AP Invoice')
    else
      title = 'GRPO'
    end
    "#{title} Request"
  end

    def rejection_reason_text
      self.grpo_rejection_reason == 'Others' ? self.grpo_other_rejection_reason : self.grpo_rejection_reason
    end

    def show_display_reason
      data = {display: true}
      case self.status
      when 'GRPO Request Rejected'
        data[:label] = 'GRPO Rejection Reason'
        data[:text] = self.grpo_rejection_reason == 'Others' ? self.grpo_other_rejection_reason : self.grpo_rejection_reason
      when 'AP Invoice Request Rejected'
        data[:label] = 'AP Rejection Reason'
        data[:text] = self.ap_rejection_reason
      when 'Cancelled GRPO'
        data[:label] = 'AP Rejection Reason'
        data[:text] = self.grpo_cancellation_reason
      when 'Cancelled AP Invoice'
        data[:label] = 'AP Rejection Reason'
        data[:text] = self.ap_cancellation_reason
      else
        data[:display] = false
      end
      data
    end


  def display_reason(type = nil)
    # If status is cancelled then also all rejection as well as other cacellation display on first load of form to avoid that ui helper written
    case type
    when 'other'
      (('GRPO Request Rejected' == self.status) && self.grpo_rejection_reason == 'Others') ? '' : 'd-none'
    when 'ap_rejection'
      ('AP Invoice Request Rejected' == self.status) ? '' : 'd-none'
    when 'grpo_rejection'
      ('GRPO Request Rejected' == self.status) ? '' : 'd-none'
    when 'grpo_cancellation'
      ('Cancelled GRPO' == self.status) ? '' : 'd-none'
    when 'ap_cancellation'
      ('Cancelled AP Invoice' == self.status) ? '' : 'd-none'
    end
  end

  def allow_statuses(overseer)
    statuses = InvoiceRequest.statuses
    disabled_statuses = []
    if self.status == 'Inward Completed'
      disabled_statuses = InvoiceRequest.statuses.keys
    elsif overseer.accounts? || overseer.admin?
      if self.status == 'GRPO Pending'
        statuses =  InvoiceRequest.statuses.except('Cancelled AP Invoice', 'Cancelled AR Invoice', 'Cancelled', 'AP Invoice Request Rejected')
      elsif self.status == 'Pending AP Invoice'
        statuses =  InvoiceRequest.statuses.except('Cancelled GRPO', 'Cancelled AR Invoice', 'Cancelled', 'GRPO Request Rejected')
      elsif self.status == 'Pending AR Invoice'
        statuses =  InvoiceRequest.statuses.except('Cancelled GRPO', 'Cancelled AP Invoice', 'Cancelled', 'AP Invoice Request Rejected', 'GRPO Request Rejected')
      end
    elsif overseer.logistics?
      if self.status == 'GRPO Request Rejected'
        disabled_statuses =  InvoiceRequest.statuses.except('In stock', 'GRPO Pending').keys
      elsif self.status == 'AP Invoice Request Rejected'
        disabled_statuses =  InvoiceRequest.statuses.except('In stock', 'Pending AP Invoice').keys
      elsif  self.status == 'In stock'
        disabled_statuses =  InvoiceRequest.statuses.except('Inward Completed').keys
      else
        disabled_statuses =  InvoiceRequest.statuses.except('In stock').keys
      end
    end
    {enabled: statuses, disabled: disabled_statuses}
  end

  def to_s
    [readable_status, "##{self.id}"].join(' ')
  end

  private

    def presence_of_reason
      case status
      when 'GRPO Request Rejected'
        if !grpo_rejection_reason.present?
          errors.add(:base, 'Please enter reason for GRPO request rejection')
        elsif grpo_rejection_reason == 'Others' && !grpo_other_rejection_reason.present?
          errors.add(:base, 'Please enter reason for GRPO request rejection')
        end
      when 'AP Invoice Request Rejected'
        if !ap_rejection_reason.present?
          errors.add(:base, 'Please enter reason for AP Invoice rejection')
        end
      when 'Cancelled GRPO'
        if !grpo_cancellation_reason.present?
          errors.add(:base, 'Please enter reason for GRPO request cancellation')
        end
      when 'Cancelled AP Invoice'
        if !ap_cancellation_reason.present?
          errors.add(:base, 'Please enter reason for AP request cancellation')
        end
      else
      end
    end
  def send_notification_on_status_changed
    if self.saved_change_to_status?
      tos = Services::Overseers::Notifications::Recipients.invoice_request_notifiers
      sender = [self.created_by.email]
      if self.status == 'GRPO Pending'
        comment = "GRPO ID ##{self.id} for  PO ##{self.purchase_order.po_number} Inquiry# #{self.inquiry.inquiry_number} has been requested"
      elsif status == 'Pending AP Invoice'
        comment = "GRPO  ##{self.grpo_number} for  PO ##{self.purchase_order.po_number} Inquiry# #{self.inquiry.inquiry_number} status changed to #{self.status}"
      elsif status == 'Cancelled GRPO'
        comment = "GRPO ID ##{self.id} for  PO ##{self.purchase_order.po_number} Inquiry# #{self.inquiry.inquiry_number} has been Cancelled. Reason: " + self.show_display_reason[:text]
      elsif status == 'GRPO Request Rejected'
        comment = "GRPO ID ##{self.id} for  PO ##{self.purchase_order.po_number} Inquiry# #{self.inquiry.inquiry_number} has been Rejected. Reason: " + self.show_display_reason[:text]
      elsif status == 'Cancelled AP Invoice'
        comment = "AP ##{self.id} for  PO ##{self.purchase_order.po_number} Inquiry# #{self.inquiry.inquiry_number} has been Cancelled. Reason: " + self.show_display_reason[:text]
      elsif self.status == 'Inward Completed'
        comment = "AP ##{self.ap_invoice_number} for  PO ##{self.purchase_order.po_number} Inquiry# #{self.inquiry.inquiry_number} has been Approved"
      end
      action_name = ''
      if self.saved_change_to_id?
        action_name = 'create'
        overseer = self.created_by
      else
        action_name = 'update'
        overseer = self.updated_by
      end
      @notification = Services::Overseers::Notifications::Notify.new(overseer, self.class.parent)
      @notification.send_invoice_request_update(
        tos,
          sender,
          action_name.to_sym,
          self,
          "/overseers/ar_invoice_requests/#{self.hashid}",
          comment,
          )
    end
  end
end
