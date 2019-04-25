class ArInvoice < ApplicationRecord
  COMMENTS_CLASS = 'ARInvoiceComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments


  belongs_to :sales_order
  belongs_to :inquiry
  has_many :inward_dispatches
  update_index('ar_invoices#ar_invoice') {self}

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

  def update_status(status)
    if ['Cancelled AR Invoice', 'AR Invoice Request Rejected'].include? (status)
      self.status = status
    elsif self.ar_invoice_number.present?
      self.status = :'Completed AR Invoice Request'
    else
      self.status = status
    end
  end

  def display_reason(type = nil)
    # If status is cancelled then also all rejection as well as other cacellation display on first load of form to avoid that ui helper written
    case type
    when 'other'
      (('AR Invoice requested' == self.status) && self.rejection_reason == 'Others') ? '' : 'd-none'
    when 'ar_rejection'
      ('AR Invoice requested' == self.status) ? '' : 'd-none'
    when 'ar_cancellation'
      ('Cancelled AR Invoice' == self.status) ? '' : 'd-none'

    end
  end


end
