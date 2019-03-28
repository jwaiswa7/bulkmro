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

  has_many_attached :files

  validates_presence_of :from, :to, :subject

  enum email_type: {
      'Sending PO to Supplier': 10,
      'Dispatch from Supplier Delayed': 20,
      'Material Received in BM Warehouse': 30,
      'Material Dispatched to Customer': 40,
      'Material Delivered to Customer': 50
  }

  after_initialize :set_defaults, if: :new_record?
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
end