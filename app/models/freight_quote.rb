class FreightQuote < ApplicationRecord
  COMMENTS_CLASS = 'FreightQuoteComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  belongs_to :freight_request

  belongs_to :inquiry
  has_one :sales_order, :through => :freight_request
  has_one :sales_quote, :through => :freight_request
  has_many_attached :attachments

  def set_defaults
    self.iec_code ||= '0316935051'
    self.exchange_rate ||= 1
  end
end
