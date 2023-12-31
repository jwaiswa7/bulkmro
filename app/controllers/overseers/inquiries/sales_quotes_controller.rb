class Overseers::Inquiries::SalesQuotesController < Overseers::Inquiries::BaseController
  before_action :set_sales_quote, only: [:edit, :update, :show, :preview, :reset_quote, :relationship_map, :get_relationship_map_json, :reset_quote_form, :sales_quote_reset_by_manager]

  def index
    @model_name = 'sales_quotes'
    @sales_quotes = @inquiry.sales_quotes.order(created_at: :desc)
    authorize_acl @sales_quotes
  end

  def show
    authorize_acl @sales_quote

    is_revision_visible = params[:is_revision_visible]
    locals = { is_revision_visible:  is_revision_visible, pagination: true }
    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for(@sales_quote, locals: locals)
      end
    end
  end

  def new
    if @inquiry.valid?
      inquiry_product_suppliers = params['inquiry_product_supplier_ids']
      @sales_quote = @inquiry.sales_quotes.build(overseer: current_overseer)
      @sales_quote = Services::Overseers::SalesQuotes::BuildRows.new(@sales_quote, inquiry_product_suppliers).call
      authorize_acl :sales_quote, 'new'
    else
      flash[:notice] = 'Inquiry Dates are Invalid'
      redirect_to request.referer

    end
  end


  def rfq_review
    @sales_quote = @inquiry.sales_quotes.build(overseer: current_overseer)
    inquiry_product_suppliers = params['inquiry_product_supplier_ids'] if params['inquiry_product_supplier_ids'].present?
    @sales_quote = Services::Overseers::SalesQuotes::BuildRows.new(@sales_quote, inquiry_product_suppliers).call
    authorize_acl :sales_quote, 'new'
  end

  def new_revision
    inquiry_product_suppliers = params['inquiry_product_supplier_ids']
    @old_sales_quote = @inquiry.sales_quotes.find(params[:id])
    @sales_quote = Services::Overseers::SalesQuotes::BuildFromSalesQuote.new(@old_sales_quote, current_overseer, inquiry_product_suppliers).call

    authorize_acl @old_sales_quote
    render 'new'
  end

  def create
    @sales_quote = SalesQuote.new(sales_quote_params.merge(overseer: current_overseer))
    authorize_acl @sales_quote

    callback_method = %w(save update_sent_at_field save_and_preview).detect {|action| params[action]}

    if callback_method.present? && send(callback_method)
      Services::Overseers::Inquiries::UpdateStatus.new(@sales_quote, :sales_quote_saved).call
      redirect_to overseers_inquiry_sales_quotes_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
    else
      render 'new'
    end
  end

  def edit
    @sales_quote = Services::Overseers::SalesQuotes::BuildRows.new(@sales_quote).call
    authorize_acl @sales_quote
  end

  def update
    @sales_quote.assign_attributes(sales_quote_params.merge(overseer: current_overseer))
    authorize_acl @sales_quote

    callback_method = %w(save update_sent_at_field save_and_preview).detect {|action| params[action]}

    if callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_quotes_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
    else
      render 'edit'
    end
  end

  def preview
    authorize_acl @sales_quote
  end

  def reset_quote
    if @inquiry.valid?
      authorize_acl @sales_quote
      @inquiry.update_attributes(quotation_uid: '')
      @inquiry.final_sales_quote.update_attributes(remote_uid: '')
      # @inquiry.final_sales_quote.save_and_sync
      redirect_to overseers_inquiry_sales_quotes_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      flash[:notice] = 'Inquiry Dates are Invalid'
      redirect_to request.referer
    end
  end


  def relationship_map
    authorize_acl @sales_quote
  end

  def get_relationship_map_json
    authorize_acl @sales_quote
    inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(@inquiry, [@sales_quote]).call
    render json: {data: inquiry_json}
  end

  def reset_quote_form
    authorize_acl @sales_quote
    @sales_quote = SalesQuote.find(params[:id])
    @inquiry = Inquiry.find(params[:inquiry_id])
    respond_to do |format|
      format.html {render partial: 'reset_sales_quote', locals: {inquiry: @inquiry, sales_quote: @sales_quote}}
    end
  end

  def sales_quote_reset_by_manager
    if @inquiry.valid?
      if params['inquiry']['comments_attributes']['0']['message'].present?
        service = Services::Overseers::SalesQuotes::SalesQuoteResetByManager.new(@sales_quote, params.merge(overseer: current_overseer))
        service.call
        flash[:notice] = 'Inquiry has been successfully changed.'
        render json: {url: overseers_inquiry_sales_quotes_path(@inquiry)}, status: 200
      else
        render json: {error: {base: 'Reset Quote Reason must be present.'}}, status: 500
      end
    else
      render json: {error: {base: 'Inquiry Dates are Invalid'}}, status: 500
    end
    authorize_acl @sales_quote
  end

  private
    def save
      service = Services::Overseers::SalesQuotes::ProcessAndSave.new(@sales_quote)
      service.call
    end

    def update_sent_at_field
      @sales_quote.update_attributes(sent_at: Time.now)
      redirect_to overseers_inquiry_sales_quotes_path(@inquiry), notice: flash_message(@inquiry, action_name)
    end

    def save_and_preview
      service = Services::Overseers::SalesQuotes::ProcessAndSave.new(@sales_quote)
      service.call
      redirect_to preview_overseers_inquiry_sales_quote_path(@inquiry, @sales_quote), notice: flash_message(@inquiry, action_name) if @sales_quote.valid?
    end

    def set_sales_quote
      @sales_quote = @inquiry.sales_quotes.find(params[:id])
    end

    def sales_quote_params
      params.require(:sales_quote).permit(:inquiry_id,
          :parent_id,
          :billing_address_id,
          :shipping_address_id,
          :comments,
          inquiry_currency_attributes: [
              :id,
              :currency_id,
              :conversion_rate,
          ],
          rows_attributes: [
              :id,
              :sales_quote_id,
              :tax_code_id,
              :tax_rate_id,
              :inquiry_product_supplier_id,
              # :inquiry_product_id,
              :lead_time_option_id,
              :quantity,
              :freight_cost_subtotal,
              :unit_freight_cost,
              :measurement_unit_id,
              :margin_percentage,
              :unit_selling_price,
              :_destroy
          ],
          selected_suppliers: {}
      )
    end
end
