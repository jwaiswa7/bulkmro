class Services::Shared::Migrations::AddInquiryMappingTat < Services::Shared::Migrations::Migrations
  def add_inquiry_mapping_tats
    start_date = Date.parse('01-01-2019')
    end_date = Date.today
    inquiries = Inquiry.includes(:sales_orders).where(created_at: start_date..end_date).where.not(status: 'Expected Order')
    Chewy.strategy(:bypass) do
      inquiries.find_each(batch_size: 100) do |inquiry|
        if inquiry.sales_orders.present?
          inquiry.sales_orders.each do |sales_order|
            InquiryMappingTat.where(inquiry_id: inquiry.id, sales_order_id: sales_order.id, sales_quote_id: sales_order.sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
          end
          inquiry.sales_quotes.each do |sales_quote|
            InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
          end
        elsif inquiry.sales_quotes.present?
          inquiry.sales_quotes.each do |sales_quote|
            InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
          end
        else
          InquiryMappingTat.where(inquiry_id: inquiry.id, inquiry_created_at: inquiry.created_at).first_or_create
        end
      end
    end
  end

  def add_missing_inquiries_in_inquiry_mapping_tat
    start_date = Date.parse('01-01-2019')
    end_date = Date.today
    inquiries = Inquiry.where(created_at: start_date..end_date).where(status: ['New Inquiry', 'Acknowledgement Mail'])
    Chewy.strategy(:bypass) do
      inquiries.find_each(batch_size: 100) do |inquiry|
        if inquiry.status == 'New Inquiry'
          InquiryStatusRecord.where(status: inquiry.status, inquiry: inquiry, subject_type: 'Inquiry', subject_id: inquiry.id).first_or_create
          InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: nil, sales_order_id: nil, inquiry_created_at: inquiry.created_at).first_or_create
        elsif inquiry.status == 'Acknowledgement Mail'
          InquiryStatusRecord.where(status: 'Acknowledgement Mail', inquiry: inquiry, subject_type: 'Inquiry', subject_id: inquiry.id, created_at: inquiry.updated_at).first_or_create
          InquiryStatusRecord.where(status: 'New Inquiry', inquiry: inquiry, subject_type: 'Inquiry', subject_id: inquiry.id, created_at: inquiry.created_at).first_or_create
          InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: nil, sales_order_id: nil, inquiry_created_at: inquiry.created_at).first_or_create
        end
      end
    end
  end

  def add_new_inquiry_status
    start_date = Date.parse('01-04-2019')
    end_date = Date.today
    inquiries = Inquiry.where(created_at: start_date..end_date)
    Chewy.strategy(:bypass) do
      inquiries.each do |inquiry|
        isr = InquiryStatusRecord.where(inquiry_id: inquiry).where(status: 'New Inquiry')
        unless isr.present?
          InquiryStatusRecord.create(status: 'New Inquiry', inquiry_id: inquiry.id, subject_type: 'Inquiry', subject_id: inquiry.id, created_at: inquiry.created_at)
        end
      end
    end
  end

  def add_parent_id_for_existing_records
    start_date = Date.parse('01-08-2019')
    end_date = Date.today.end_of_day
    inquiries = Inquiry.where(created_at: start_date..end_date)
    Chewy.strategy(:bypass) do
      inquiries.find_each(batch_size: 250) do |inquiry|
        inquiry.inquiry_status_records.where.not(status: ['New Inquiry']).each do |isr|
          previous_status_record = isr.fetch_previous_status_record
          isr.update_attributes(previous_status_record_id: previous_status_record.id) if previous_status_record.present?
        end
      end
    end
  end

  def add_tat_for_existing_records
    start_date = Date.parse('01-08-2019')
    end_date = Date.today.end_of_day
    inquiry_status_records = InquiryStatusRecord.where(created_at: start_date..end_date).where.not(previous_status_record_id: nil).where(tat_minutes: nil)
    inquiry_status_records.each do |inquiry_status_record|
      if inquiry_status_record.present?
        previous_status = inquiry_status_record.previous_status_record
        minutes = previous_status.present? ? inquiry_status_record.calculate_turn_around_time(previous_status) : ''
        inquiry_status_record.update_attributes(tat_minutes: minutes) if minutes.present?
      end
    end
  end
end
