class EmailMessage < ApplicationRecord
  belongs_to :overseer, required: false
  belongs_to :contact, required: false
  belongs_to :company, required: false
  belongs_to :account, required: false
  belongs_to :inquiry, required: false
  belongs_to :sales_quote, required: false
  belongs_to :purchase_order, required: false
  belongs_to :sales_order, required: false
  belongs_to :sales_invoice, required: false
  belongs_to :outward_dispatch, required: false
  belongs_to :supplier_rfq, required: false
  belongs_to :customer_rfq, required: false
  belongs_to :activity, required: false
  belongs_to :revision_request, required: false

  # Added polymophic relationship
  belongs_to :emailable, polymorphic: true

  has_many_attached :files

  validates_presence_of :from, :to, :subject

  enum email_type: {
      'Sending PO to Supplier': 10,
      'Dispatch from Supplier Delayed': 20,
      'Material Received in BM Warehouse': 30,
      'Material Dispatched to Customer': 40,
      'Material Delivered to Customer': 50,
      'Inventory Status Update to Saint Gobain': 60,
      'Request for Quote': 70,
      'Request for SO Cancellation': 80,
      'Revison request created': 90
  }

  after_initialize :set_defaults, if: :new_record?
  after_create :set_flag_in_email_message_sent

  def set_defaults
    if inquiry.present?
      self.subject ||= self.inquiry.subject
    end

    if self.overseer.present?
      self.from ||= self.overseer.email
    end

    if self.contact.present?
      self.to ||= self.contact.email
    end

    self.auto_attach ||= false
  end

  def set_flag_in_email_message_sent
    case self.email_type
    when 'Material Dispatched to Customer'
      if self.sales_invoice.present? && self.sales_invoice.ar_invoice_request.present?
        outward_dispatches = self.sales_invoice.outward_dispatches
        outward_dispatches.update_all(dispatch_mail_sent_to_the_customer: true)
        OutwardDispatchesIndex::OutwardDispatch.import([outward_dispatches.pluck(:id)])
      elsif self.outward_dispatch
        outward_dispatch = self.outward_dispatch
        if !(outward_dispatch.status == 'Material Delivered')
          outward_dispatch.update_attributes(dispatch_mail_sent_to_the_customer: true, status: 'Material Dispatched')
        else
          outward_dispatch.update_attributes(dispatch_mail_sent_to_the_customer: true)
        end
      end
    when 'Material Delivered to Customer'
      if self.sales_invoice.present? && self.sales_invoice.ar_invoice_request.present?
        outward_dispatches = self.sales_invoice.outward_dispatches
        outward_dispatches.update_all(material_delivered_mail_sent_to_customer: true)
        OutwardDispatchesIndex::OutwardDispatch.import([outward_dispatches.pluck(:id)])
      end
    end
  end
end
