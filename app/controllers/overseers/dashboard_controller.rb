class Overseers::DashboardController < Overseers::BaseController
  skip_before_action :authenticate_overseer!, only: :migrations

  def show
    authorize_acl :dashboard

    # if Rails.env.development?
    #   render 'default_dashboard'
    # else
    if current_overseer.sales?
      if current_overseer.descendant_ids.present?
        redirect_to sales_manager_overseers_dashboard_path
      else
        redirect_to sales_executive_overseers_dashboard_path
      end
    elsif current_overseer.acl_accounts?
      redirect_to accounts_overseers_dashboard_path
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

  def sales_manager
    @dashboard = Overseers::Dashboard.new(current_overseer)
    render template: 'overseers/dashboard/sales_manager/sales_manager_dashboard'
  end

  def sales_executive
    @dashboard = Overseers::Dashboard.new(current_overseer)
    render template: 'overseers/dashboard/sales_executive/new_sales_dashboard'
  end

  def accounts
    @dashboard = Overseers::Dashboard.new(current_overseer)
    render template: 'overseers/dashboard/accounts/accounts_dashboard'
  end

  def follow_up_dashboard
    if current_overseer.inside_sales_executive?
      @dashboard = Overseers::Dashboard.new(current_overseer)
      render 'sales_dashboard'
    end
  end

  def get_status_records
    inquiry = Inquiry.find_by_inquiry_number(params['inquiry_number'])
    inquiry_status_records = inquiry.inquiry_status_records.order(created_at: :desc).group_by { |c| c.created_at.to_date }
    if inquiry_status_records
      respond_to do |format|
        format.html { render partial: 'overseers/dashboard/common/inq_status_records_data', locals: {inquiry_status_records: inquiry_status_records, inquiry: inquiry} }
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
      format.html { render partial: 'overseers/dashboard/common/email_message', locals: {inquiry: inquiry, email_message: email_message} }
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


  def update_invoice_request
    invoice_request = InvoiceRequest.find_by_id(params['invoice_request']['invoice_request_id'])

    if params['invoice_request']['grpo_number'].present?
      # invoice_request.update_attribute('grpo_number', params['invoice_request']['grpo_number'].to_i)
      invoice_request.grpo_number = params['invoice_request']['grpo_number'].to_i
    end
    if params['invoice_request']['ap_invoice_number'].present?
      # invoice_request.update_attribute('ap_invoice_number', params['invoice_request']['ap_invoice_number'].to_i)
      invoice_request.ap_invoice_number = params['invoice_request']['grpo_number'].to_i
    end
    service = Services::Overseers::InvoiceRequests::Update.new(invoice_request, current_overseer)
    service.call
    redirect_back fallback_location: overseers_dashboard_path
  end

  def get_filtered_inquiries
    Rails.cache.fetch([self, 'get_filtered_inquiries'], expires_in: 1.hours) do
      @dashboard = Overseers::Dashboard.new(current_overseer)
      executive_link = params['executive_link'].to_s.downcase == 'true' if params.key?('executive_link')
      if current_overseer.sales? && current_overseer.descendant_ids.present? && !executive_link
        # for role = Inside Sales Manager
        inquiry_as_per_box = Inquiry.with_includes.where('created_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where(status: @dashboard.main_statuses[params['status']], inside_sales_owner_id: current_overseer.self_and_descendant_ids).order(updated_at: :desc).compact.group_by(&:inside_sales_owner_id)
        inquiry_as_per_box = inquiry_as_per_box.map { |id, inquiries| [Overseer.find_by_id(id).name, inquiries] }.to_h
        respond_to do |format|
          format.html {render partial: 'overseers/dashboard/sales_manager/inquiry_list_sales_manager_wrapper', locals: {inq_for_sales_manager_dash: inquiry_as_per_box}}
        end
      elsif current_overseer.sales? && !current_overseer.descendant_ids.present?
        # for role = sales_executives
        respond_to do |format|
          format.html {render partial: 'overseers/dashboard/common/inquiry_list_wrapper', locals: {inq_for_dash: @dashboard.inq_for_dash(executive_link).map { |inquiry| inquiry if inquiry.status == params['status'] }.compact, executivelink: executive_link }}
        end
      else
        # for role = accounts
        if params['status'] == 'GRPO Pending'
          respond_to do |format|
            format.html {render partial: 'overseers/dashboard/common/inquiry_list_wrapper', locals: {inq_for_dash: Inquiry.where(id: @dashboard.invoice_requests_grpo_pending.pluck(:inquiry_id)), executivelink: executive_link }}
          end
        elsif params['status'] == 'Pending AP Invoice'
          respond_to do |format|
            format.html {render partial: 'overseers/dashboard/common/inquiry_list_wrapper', locals: {inq_for_dash: Inquiry.where(id: @dashboard.invoice_requests_ap_invoice_pending.pluck(:inquiry_id)), executivelink: executive_link }}
           end
        elsif params['status'] == 'AR Invoice requested'
          respond_to do |format|
            format.html {render partial: 'overseers/dashboard/common/inquiry_list_wrapper', locals: {inq_for_dash: Inquiry.where(id: @dashboard.ar_invoice_requests.pluck(:inquiry_id)), executivelink: executive_link}}
          end
        else
          respond_to do |format|
            format.html {render partial: 'overseers/dashboard/common/inquiry_list_wrapper', locals: {inq_for_dash: @dashboard.inquiries_with_so_approval_pending, executivelink: executive_link }}
          end
        end
      end
    end
  end

  def get_inquiry_tasks
    Rails.cache.fetch([self, 'get_filtered_inquiries'], expires_in: 1.hours) do
      @dashboard = Overseers::Dashboard.new(current_overseer)
      executive_link = params['executive_link'].to_s.downcase == 'true' if params.key?('executive_link')
      if current_overseer.sales?
        # if current_overseer.descendant_ids.present?
        inquiry = []
        @dashboard.inq_for_dash(executive_link).each do |inq|
          if inq.inquiry_number == params['inquiry_number'].to_i
            inquiry.push inq
            break
          end
        end
        # else
        #   inquiry = @dashboard.inq_for_dash.where(inquiry_number: params['inquiry_number'].to_i)
        # end

        # if inquiry.last.customer_po_number.blank? || inquiry.last.customer_order_date.blank? || (inquiry.last.approvals.any? && inquiry.last.inquiry_product_suppliers.any? && inquiry.last.sales_quotes.persisted.blank?) || (inquiry.last.final_sales_quote.present? && policy(inquiry.last.final_sales_quote).new_sales_order?)
        inquiry_has_tasks = true
        # else
        #   inquiry_has_tasks = false
        # end
        respond_to do |format|
          format.html {render partial: 'overseers/dashboard/sales_executive/task_list_wrapper', locals: {inq_for_dash: inquiry, show_all_tasks: false, show_inquiry_tasks: true, inquiry_has_tasks: inquiry_has_tasks}}
        end

      elsif current_overseer.acl_accounts?
        inquiry = []
        @dashboard.inq_for_account_dash.each do |inq|
          if inq.inquiry_number == params['inquiry_number'].to_i
            inquiry.push inq
            break
          end
        end

        respond_to do |format|
          format.html {render partial: 'overseers/dashboard/accounts/account_task_list_wrapper', locals: {inq_for_dash: inquiry, show_all_tasks: false, show_inquiry_tasks: true, inquiry_has_tasks: true}}
        end
      end
    end
  end


  def get_account_executive_data
    current_overseer = Overseer.where(email: params['account_exe']).last
    @dashboard = Overseers::Dashboard.new(current_overseer)
    respond_to do |format|
      format.html {render partial: "overseers/dashboard/accounts/left_panel_account_dashboard", locals: { main_statuses: @dashboard.main_statuses_accounts(params['account_exe']), executivelink: nil }}
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

  def my_team
    service = Services::Overseers::Finders::MyTeam.new(params, current_overseer)
    service.call
    records = service.records
    overseers = current_overseer.self_and_descendants
    report_bucket_service = Services::Overseers::Dashboards::MyTeamBuckets.new(records, overseers, params)
    @bucket_records = report_bucket_service.call
    render json: { html: render_to_string(partial: 'overseers/dashboard/sales_manager/my_team_sales_manager_dashboard', locals: { records: @bucket_records }) }
  end

  def get_recent_inquiries
    overseer = Overseer.find(params['overseer_id'])
    @inquiries = Inquiry.where(inside_sales_owner_id: overseer.id).or(Inquiry.where(outside_sales_owner_id: overseer.id)).order('created_at DESC').first(10)
    respond_to do |format|
      format.html { render partial: '/overseers/dashboard/sales_manager/inquiries_dropdown_my_team', locals: {inquiries: @inquiries, name: overseer.first_name, id: overseer.id} }
    end
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
