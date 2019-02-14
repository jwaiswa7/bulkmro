

class Services::Overseers::InquiryImports::NextSrNo < Services::Shared::BaseService
  def initialize(inquiry)
    @inquiry = inquiry
    @sr_nos = inquiry.inquiry_products.pluck(:sr_no).reject { |sr_no| sr_no.blank? }
  end

  def call(sr_no)
    unique_sr_no = sr_nos.include?(sr_no.to_i) ? sr_nos.map(&:to_i).max + 1 : sr_no
    sr_nos << unique_sr_no
    unique_sr_no
  end

  attr_accessor :inquiry, :sr_no, :sr_nos
end
