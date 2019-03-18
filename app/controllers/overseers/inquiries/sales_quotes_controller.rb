class Overseers::Inquiries::SalesQuotesController < Overseers::Inquiries::BaseController
  before_action :set_sales_quote, only: [:edit, :update, :show, :preview, :reset_quote, :relationship_map, :get_relationship_map_json]

  def index
    @sales_quotes = @inquiry.sales_quotes
    authorize @sales_quotes
  end

  def show
    authorize @sales_quote

    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @sales_quote
      end
    end
  end

  def new
    @sales_quote = @inquiry.sales_quotes.build(overseer: current_overseer)
    @sales_quote = Services::Overseers::SalesQuotes::BuildRows.new(@sales_quote).call
    authorize @inquiry, :new_sales_quote?
  end

  def new_revision
    @old_sales_quote = @inquiry.sales_quotes.find(params[:id])
    @sales_quote = Services::Overseers::SalesQuotes::BuildFromSalesQuote.new(@old_sales_quote, current_overseer).call

    authorize @old_sales_quote
    render 'new'
  end

  def create
    @sales_quote = SalesQuote.new(sales_quote_params.merge(overseer: current_overseer))
    authorize @sales_quote

    callback_method = %w(save update_sent_at_field save_and_preview).detect { |action| params[action] }

    if callback_method.present? && send(callback_method)
      Services::Overseers::Inquiries::UpdateStatus.new(@sales_quote, :sales_quote_saved).call
      redirect_to overseers_inquiry_sales_quotes_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
    else
      render 'new'
    end
  end

  def edit
    @sales_quote = Services::Overseers::SalesQuotes::BuildRows.new(@sales_quote).call
    authorize @sales_quote
  end

  def update
    @sales_quote.assign_attributes(sales_quote_params.merge(overseer: current_overseer))
    authorize @sales_quote

    callback_method = %w(save update_sent_at_field save_and_preview).detect { |action| params[action] }

    if callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_quotes_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
    else
      render 'edit'
    end
  end

  def preview
    authorize @sales_quote
  end

  def reset_quote
    authorize @sales_quote
    @inquiry.update_attributes(quotation_uid: '')
    @inquiry.final_sales_quote.update_attributes(remote_uid: '')
    # @inquiry.final_sales_quote.save_and_sync
    redirect_to overseers_inquiry_sales_quotes_path(@inquiry), notice: flash_message(@inquiry, action_name)
  end


  def relationship_map
    authorize @sales_quote
  end

  def get_relationship_map_json
    authorize @sales_quote
    sales_quote_array = []
    sales_quote_array << @sales_quote
    inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(@inquiry,sales_quote_array).call
    render json: {data: inquiry_json}
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
      params.require(:sales_quote).permit(
        :inquiry_id,
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
