# frozen_string_literal: true

class EmailMessage < ApplicationRecord
  belongs_to :overseer, required: false
  belongs_to :contact, required: false
  belongs_to :company, required: false
  belongs_to :account, required: false


  has_many_attached :files

  belongs_to :inquiry, required: false
  belongs_to :sales_quote, required: false
  belongs_to :purchase_order, required: false
  belongs_to :sales_order, required: false
  belongs_to :sales_invoice, required: false

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
    self.subject ||= inquiry.subject if inquiry.present?

    self.from ||= overseer.email if overseer.present?

    self.to ||= contact.email if contact.present?

    self.auto_attach ||= false
  end
end
