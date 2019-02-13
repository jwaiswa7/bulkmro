

class Services::Overseers::Inquiries::HandleSmartQueue < Services::Shared::BaseService
  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    quote_total = inquiry.calculated_total > 0 ? inquiry.calculated_total : inquiry.potential_amount

    value_score = if quote_total.present?
      if quote_total <= 100000
        1
      elsif quote_total <= 200000
        2
      elsif quote_total <= 500000
        3
      elsif quote_total >= 500000
        4
      end
    else
      1
    end

    stage_multiplier = if inquiry.status.in? ["Quotation Sent", "Follow Up on Quotation", "Expected Order", "SO Not Created-Customer PO Awaited", "SO Not Created-Pending Customer PO Revision"]
      2
    else
      1
    end

    client_score = if inquiry.company.priority_strategic?
      1
    else
      0.5
    end

    final_score = (value_score * stage_multiplier) + client_score
    final_score += 100 if inquiry.quotation_followup_date.present? && 1770.minutes.from_now >= inquiry.quotation_followup_date

    inquiry.update_attributes!(priority: final_score)
  end

  attr_accessor :inquiry
end
