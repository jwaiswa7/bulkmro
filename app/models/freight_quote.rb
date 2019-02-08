# frozen_string_literal: true

class FreightQuote < ApplicationRecord
  COMMENTS_CLASS = "FreightQuoteComment"

  include Mixins::CanBeStamped
  include Mixins::HasComments

  belongs_to :freight_request

  belongs_to :inquiry
  belongs_to :purchase_order, optional: true
  has_one :sales_order, through: :freight_request
  has_one :sales_quote, through: :freight_request
  has_many_attached :attachments

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.iec_code ||= "0316935051"
  end
end
