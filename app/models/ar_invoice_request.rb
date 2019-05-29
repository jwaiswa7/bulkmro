class ArInvoiceRequest < ApplicationRecord
  COMMENTS_CLASS = 'ArInvoiceRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments


  belongs_to :sales_order
  belongs_to :inquiry
  has_many :inward_dispatches
  has_many :outward_dispatches
  validate :presence_of_reason
  after_save :send_notification_on_status_changed

  has_many :rows, class_name: 'ArInvoiceRequestRow', inverse_of: :ar_invoice_request

  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| attributes['inward_dispatch_row_id'].blank? }, allow_destroy: true
  validates_associated :rows, dependent: :destroy

  update_index('ar_invoice_Requests#ar_invoice_request') {self}

  enum status: {
      'AR Invoice requested': 10,
      'Cancelled AR Invoice': 20,
      'AR Invoice Request Rejected': 30,
      'Completed AR Invoice Request': 40
  }

  enum rejection_reason: {
      'Rejected: Product not in Stock': 10,
      'Rejected: Product Qty Fulfilled': 20,
      'Rejected: Others': 30

  }

  scope :with_includes, -> {}

  enum cancellation_reason: {

      'Freight Charges': 10,
      'Installation Charges': 20,
      'Others': 30

  }

  with_options if: :"Completed AR Invoice Request?" do |invoice_request|
    invoice_request.validates_presence_of :ar_invoice_number
    invoice_request.validates :ar_invoice_number, length: { is: 8 }, allow_blank: true
    invoice_request.validates_numericality_of :ar_invoice_number, allow_blank: true
  end

  def update_status(status)
    if ['Cancelled AR Invoice', 'AR Invoice Request Rejected'].include? (status)
      self.status = status
    elsif self.ar_invoice_number.present?
      self.status = :'Completed AR Invoice Request'
    else
      self.status = status
    end
  end

  def send_notification_on_status_changed
    if self.saved_change_to_status?
      if self.status == 'AR Invoice requested'
        tos = Services::Overseers::Notifications::Recipients.ar_invoice_request_notifiers
        comment = "Ar invoice number#{self.ar_invoice_number} requested"
      else
        tos = [self.created_by.email]
        if status == 'AR Invoice Request Rejected'
          comment = "Ar invoice number#{self.ar_invoice_number} rejected. Reason: " + self.show_display_reason[:text]
        elsif status == 'Cancelled AR Invoice'
          comment = "Ar invoice number#{self.ar_invoice_number} cancelled. Reason: " + self.show_display_reason[:text]
        elsif self.status == 'Completed AR Invoice Request'
          comment = "Ar invoice number#{self.ar_invoice_number} completed."
        end
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
      @notification.send_ar_invoice_request_update(
          tos ,
          action_name.to_sym,
          self,
          "/overseers/ar_invoice_requests/#{self.hashid}",
          comment,
          )
    end
  end

  def allow_statuses(overseer)
    if overseer.accounts?
      statuses = ArInvoiceRequest.statuses
      return {enabled: statuses, disabled: []}

    elsif overseer.logistics?
      if self.status == 'AR Invoice Request Rejected'
        statuses = ArInvoiceRequest.statuses.slice('AR Invoice requested')
      end
      return {enabled: ArInvoiceRequest.statuses, disabled: ArInvoiceRequest.statuses.except('AR Invoice requested').keys}
    else
      return {enabled: ArInvoiceRequest.statuses, disabled: []}
    end
  end

  def display_reason(type = nil)
    # If status is cancelled then also all rejection as well as other cacellation display on first load of form to avoid that ui helper written
    case type
    when 'other_rejection'
      (('AR Invoice Request Rejected' == self.status) && self.rejection_reason == 'Rejected: Others') ? '' : 'd-none'
    when 'other_cancellation'
      (('Cancelled AR Invoice' == self.status) && self.cancellation_reason == 'Others') ? '' : 'd-none'
    when 'rejection'
      ('AR Invoice Request Rejected' == self.status) ? '' : 'd-none'
    when 'cancellation'
      ('Cancelled AR Invoice' == self.status) ? '' : 'd-none'

    end
  end
  def reason_text(type)
    if type == 'rejection'
      self.rejection_reason == 'Rejected: Others' ? self.other_rejection_reason : self.rejection_reason
    elsif type == 'cancellation'
      self.rejection_reason == 'Others' ? self.other_cancellation_reason : self.cancellation_reason
    end
  end
  def show_display_reason
    data = {display: true}
    case self.status
    when 'AR Invoice Request Rejected'
      data[:label] = 'AR Rejection Reason'
      data[:text] = self.rejection_reason == 'Rejected: Others' ? self.other_rejection_reason : self.rejection_reason
    when 'Cancelled AR Invoice'
      data[:label] = 'AP Cancellation Reason'
      data[:text] = self.cancellation_reason == 'Others' ? self.other_cancellation_reason : self.cancellation_reason
    else
      data[:display] = false
    end
    data
  end

  def total_quantity_delivered
    self.rows.sum(:delivered_quantity)
  end

  def outward_dispatched_quantity
    self.outward_dispatches.sum(&:quantity_in_payment_slips)
  end

  def title
    'AR Invoice Request'
  end

  private

    def presence_of_reason
      case status
      when 'AR Invoice Request Rejected'
        if !rejection_reason.present?
          errors.add(:base, 'Please enter reason for AR invoice request rejection')
        elsif rejection_reason == 'Rejected: Others' && !other_rejection_reason.present?
          errors.add(:base, 'Please enter reason for AR invoice request rejection')
        end
      when 'Cancelled AR Invoice'
        if !cancellation_reason.present?
          errors.add(:base, 'Please enter reason for AR invoice request cancellation')
        elsif cancellation_reason == 'Others' && !other_cancellation_reason.present?
          errors.add(:base, 'Please enter reason for AR invoice request cancellation')
        end
      else
      end
    end
end
