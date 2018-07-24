class Overseers::Inquiries::RfqsController < Overseers::Inquiries::BaseController
  def edit_suppliers
    authorize @inquiry
  end

  def update_suppliers
    authorize @inquiry

    begin
      if @inquiry.update_attributes(edit_suppliers_params.merge(:overseer => current_overseer)) && @inquiry.inquiry_suppliers.size > 0
        redirect_to edit_rfqs_overseers_inquiry_rfqs_path(@inquiry), notice: flash_message(@inquiry, action_name)
      else
        render 'edit_suppliers'
      end
    rescue ActiveRecord::RecordInvalid => e
      render 'edit_suppliers'
    end
  end

  def edit_rfqs
    @inquiry.suppliers.uniq.each do |supplier|
      @inquiry.rfqs.build(:supplier => supplier, contacts: [RandomRecord.for(supplier.contacts)])
    end

    @inquiry.assign_attributes(:rfq_subject => 'URGENT: RFQ from Bulk MRO Industrial Supplies Pvt. Ltd.')

    authorize @inquiry
  end

  def update_rfqs
    @inquiry.assign_attributes(edit_rfqs_params.merge(:overseer => current_overseer))
    service = Services::Overseers::Rfqs::SaveAndSend.new(@inquiry)

    authorize @inquiry

    if service.call
      redirect_to overseers_inquiries_path, notice: flash_message(@inquiry, action_name)
    else
      render 'edit_rfqs'
    end
  end

  def edit_rfqs_mailer_preview
    authorize @inquiry
    render plain: InquiryMailer.rfq_generated(Rfq.new(:inquiry => @inquiry, :supplier => RandomRecord.for(@inquiry.suppliers)))
  end

  def edit_quotations
    authorize @inquiry
  end

  def update_quotations
    @inquiry.assign_attributes(edit_quotations_params)

    authorize @inquiry

    if @inquiry.save
      redirect_to new_overseers_inquiry_sales_quote_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'edit_quotations'
    end
  end

  private
  def edit_suppliers_params
    params.require(:inquiry).permit(
        :inquiry_products_attributes => [:id, :supplier_ids => []]
    )
  end

  def edit_rfqs_params
    params.require(:inquiry).permit(
      :rfq_subject,
      :rfq_comments,
      :rfqs_attributes => [:supplier_id, :inquiry_id, :contact_ids => []]
    )
  end

  def edit_quotations_params
    params.require(:inquiry).permit(
        :rfqs_attributes => [
            :id, :supplier_id, :inquiry_id,
            :inquiry_suppliers_attributes => [:id, :unit_price]
        ]
    )
  end
end