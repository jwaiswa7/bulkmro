class Services::Overseers::Inquiries::SetInquiryPriority < Services::Shared::BaseService

  def initialize(inquiry)
    @inquiry = inquiry
  end


  def set_priority
    quote_total = @inquiry.calculated_total.to_f > 0 ? @inquiry.calculated_total.to_f : @inquiry.potential_amount.to_f

    if quote_total.to_f <= 100000
      valueScore = 1
    elsif quote_total.to_f <= 200000
      valueScore = 2
    elsif quote_total.to_f <= 500000
      valueScore = 3
    elsif quote_total.to_f >= 500000
      valueScore = 4
    end

    #Check if status is in critical, i.e. Quotation sent, Followup, Expected Order, then set stage multiplier=2
    if @inquiry.status == 'Quotation Sent' || @inquiry.status == 'Follow Up on Quotation' || @inquiry.status == 'Expected Order' || @inquiry.status == 'SO Not Created-Customer PO Awaited' || @inquiry.status == 'SO Not Created-Pending Customer PO Revision'
      stageMultiplier = 2;
    else
      stageMultiplier = 1;
    end

    #Check if client is strategic then set client score to 1 else .5
    if @inquiry.company.priority == "strategic" && @inquiry.company.priority.present?
      clientScore = 1
    else
      clientScore = 0.5
    end

    finalScore = (valueScore * stageMultiplier) + clientScore

    if @inquiry.quotation_followup_date.present?
      # followuptime within 29.5 hours
      if 1770.minutes.from_now >= @inquiry.quotation_followup_date
        finalScore += 100
      end
    end

    @inquiry.update_attributes(:priority => finalScore)
  end

  attr_accessor :inquiry
end