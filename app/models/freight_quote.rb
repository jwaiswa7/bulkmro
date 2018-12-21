class FreightQuote < ApplicationRecord
  COMMENTS_CLASS = 'FreightQuoteComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  belongs_to :freight_request

  has_one :inquiry, :through => :freight_request
  has_one :sales_order, :through => :freight_request
  has_one :sales_quote, :through => :freight_request
  has_many_attached :attachments

  enum status: {
      :'Pending' => 10,
      :'Completed' => 20
  }

  def set_defaults
    self.iec_code ||= :'316935051'
  end

end
