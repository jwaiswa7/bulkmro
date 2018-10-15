class NextSrNo < BaseFunction
  def self.for(inquiry, sr_no)
    sr_nos ||= inquiry.inquiry_products.pluck(:sr_no)
    sr_no = sr_nos.map(&:to_i).max + 1 if sr_nos.include?(sr_no)
    sr_nos << sr_no
    sr_no
  end
end