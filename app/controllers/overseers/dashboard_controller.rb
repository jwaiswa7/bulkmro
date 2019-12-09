class Overseers::DashboardController < Overseers::BaseController
  skip_before_action :authenticate_overseer!, only: :migrations

  def show
    authorize_acl :dashboard

    # if Rails.env.development?
    #   render 'default_dashboard'
    # else
    if current_overseer.inside_sales_executive?
      @dashboard = Overseers::Dashboard.new(current_overseer)
      render 'new_sales_dashboard'
    elsif current_overseer.admin?
      @dashboard = Rails.cache.fetch('admin_dashboard_data') do
        service = Services::Overseers::Dashboards::Admin.new
        @dashboard = service.call
      end
      render 'admin_dashboard'
    else
      render 'default_dashboard'
    end
    # end
  end

  def get_status_records
    inquiry = Inquiry.find_by_inquiry_number(params['inquiry_number'])
    inquiry_status_records = inquiry.inquiry_status_records.order(created_at: :desc).group_by { |c| c.created_at.to_date }
    if inquiry_status_records
      respond_to do |format|
        format.html { render partial: 'overseers/dashboard/inq_status_records_data', locals: {inquiry_status_records: inquiry_status_records, inquiry: inquiry} }
      end
    end
  end

  def show_email_message_modal
    inquiry = Inquiry.find_by_inquiry_number(params['inquiry_number'])
    email_message = inquiry.email_messages.build(overseer: current_overseer, contact: inquiry.contact, inquiry: inquiry)
    email_message.assign_attributes(
        subject: inquiry.subject,
        body: InquiryMailer.acknowledgement(email_message).body.raw_source,
    )
    respond_to do |format|
      format.html { render partial: 'overseers/dashboard/email_message', locals: {inquiry: inquiry, email_message: email_message} }
    end
  end

  def update_inquiry
    inquiry = Inquiry.find_by_inquiry_number(inquiry_params['inquiry_number'])
    if inquiry_params['customer_po_number'].present?
      inquiry.update_attributes(customer_po_number: inquiry_params['customer_po_number'])
    else
      inquiry.update_attributes(customer_order_date: inquiry_params['customer_order_date'])
    end
    redirect_back fallback_location: overseers_dashboard_path
  end

  def get_filtered_inquiries
    @dashboard = Overseers::Dashboard.new(current_overseer)
    respond_to do |format|
      format.html {render partial: 'inquiry_list_wrapper', locals: {inq_for_sales_dash: @dashboard.inq_for_sales_dash.map { |inquiry| inquiry if inquiry.status == params['status'] }.compact}}
    end
  end

  def get_inquiry_tasks
    @dashboard = Overseers::Dashboard.new(current_overseer)
    inquiry = @dashboard.inq_for_sales_dash.map { |inquiry| inquiry if inquiry.inquiry_number == params['inquiry_number'].to_i }.compact

    if inquiry.last.status != 'New Inquiry' && (inquiry.last.customer_po_number.present? || inquiry.last.customer_order_date.present?)
      inquiry_has_tasks = false
    else
      inquiry_has_tasks = true
    end

    respond_to do |format|
      format.html {render partial: 'task_list_wrapper', locals: {inq_for_sales_dash: inquiry, show_all_tasks: false, show_inquiry_tasks: true, inquiry_has_tasks: inquiry_has_tasks}}
    end
  end

  def serializer
    authorize_acl :dashboard, :show?
    render json: Serializers::InquirySerializer.new(Inquiry.find(1004),
                                                    include: [
                                                    ]).serialized_json
  end

  def chewy
    authorize_acl :dashboard
    Dir[[Chewy.indices_path, '/*'].join()].map do |path|
      path.gsub('.rb', '').gsub('app/chewy/', '').classify.constantize.reset!
    end
    # Fix for failure when no shards are found
    redirect_back fallback_location: overseers_dashboard_path
  end

  def reset_index
    authorize_acl :dashboard
    if params.present? && params[:index].present?
      index_class = params[:index].to_s.classify.constantize
      if index_class <= BaseIndex
        index_class.reset!
      end
    end
    redirect_back fallback_location: overseers_dashboard_path
  end

  def console
    authorize_acl :dashboard

    CustomerProduct.with_attachments.each do |customer_product|
      customer_product.best_images.each do |image|
        image.service.delete(customer_product.watermarked_variation(image, 'tiny').key)
        image.service.delete(customer_product.watermarked_variation(image, 'medium').key)
      end
    end
    # render json: Resources::BusinessPartner.find('3095267094', quotes: true)
  end

  def migrations
    authorize_acl :dashboard
    Services::Shared::Migrations::Migrations.new.call
    render json: {}, status: :ok
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(
        :inquiry_number,
        :customer_po_number,
        :customer_order_date
    )
  end
end
