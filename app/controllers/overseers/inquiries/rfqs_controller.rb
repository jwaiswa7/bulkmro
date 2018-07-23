class Overseers::Inquiries::RfqsController < Overseers::Inquiries::BaseController
  def select_suppliers
    authorize @inquiry
  end

  def suppliers_selected
    authorize @inquiry

    begin
      if @inquiry.update_attributes(select_suppliers_params.merge(:overseer => current_overseer)) && @inquiry.inquiry_suppliers.size > 0
        redirect_to generate_rfqs_overseers_inquiry_rfqs_path(@inquiry), notice: flash_message(@inquiry, action_name)
      else
        render 'select_suppliers'
      end
    rescue ActiveRecord::RecordInvalid => e
      render 'select_suppliers'
    end
  end

  def generate_rfqs
    @inquiry.suppliers.uniq.each do |supplier|
      @inquiry.rfqs.build(:supplier => supplier, contacts: [RandomRecord.for(supplier.contacts)])
    end

    @inquiry.assign_attributes(:rfq_subject => 'URGENT: RFQ from Bulk MRO Industrial Supplies Pvt. Ltd.')

    authorize @inquiry
  end

  def rfqs_generated
    @inquiry.assign_attributes(generate_rfqs_params.merge(:overseer => current_overseer))

    authorize @inquiry

    @inquiry.rfqs.each do |rfq|
      rfq.assign_attributes(
          :subject => @inquiry.rfq_subject,
          :comments => @inquiry.rfq_comments
      )
    end

    if @inquiry.save
      redirect_to overseers_inquiries_path, notice: flash_message(@inquiry, action_name)
    else
      render 'generate_rfqs'
    end
  end

  def rfqs_generated_mailer_preview
    authorize @inquiry
    render plain: InquiryMailer.rfq_generated(Rfq.new(:inquiry => @inquiry, :supplier => RandomRecord.for(@inquiry.suppliers)))
  end

  private
  def select_suppliers_params
    params.require(:inquiry).permit(
        :inquiry_products_attributes => [:id, :supplier_ids => []]
    )
  end

  def generate_rfqs_params
    params.require(:inquiry).permit(
      :rfq_subject,
      :rfq_comments,
      :rfqs_attributes => [:supplier_id, :inquiry_id, :contact_ids => []]
    )
  end
end