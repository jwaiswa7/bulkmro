class ArInvoice < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
  belongs_to :inquiry

  enum status: {
      'AR Invoice requested': 10,
      'Cancelled AR Invoice': 20,
      'AR Invoice Request Rejected': 30,
      'Completed AR Invoice Request': 40
  }

  enum grpo_rejection_reason: {
      'Rejected: Product not in Stock': 10,
      'Rejected: Product Qty Fulfilled': 20,
      'Rejected: Others': 30

  }

  def update_status(status)
    if ['Cancelled AR Invoice', 'AR Invoice Request Rejected'].include? (status)
      self.status = status
    elsif self.ar_invoice_number.present?
      self.status = :'Completed AR Invoice Request'
    else
      self.status = status
    end
  end


end
