# frozen_string_literal: true

class Overseers::FreightRequests::FreightQuotesController < Overseers::FreightRequests::BaseController
  before_action :set_freight_quote, only: %i[show edit update]

  def index
    freight_quotes = FreightQuote.all.order(id: :desc)

    @freight_quotes = ApplyDatatableParams.to(freight_quotes, params)
    authorize_acl @freight_quotes
  end

  def new
    authorize_acl @freight_request
    @freight_quote = @freight_request.build_freight_quote(overseer: current_overseer, inquiry: @freight_request.inquiry)
  end

  def show
    authorize_acl @freight_quote
  end

  def create
    authorize_acl @freight_request
    @freight_quote = FreightQuote.new(freight_quote_params.merge(overseer: current_overseer))

    if @freight_quote.valid?
      ActiveRecord::Base.transaction do
        @freight_quote.freight_request.status = 'Freight Quote Submitted'
        @freight_quote.freight_request.save!
        @freight_quote.save!
        @freight_quote_comment = FreightQuoteComment.new(message: 'Payment Request submitted.', freight_quote: @freight_quote, overseer: current_overseer)
        @freight_quote_comment.save!
      end

      redirect_to overseers_freight_quote_path(@freight_quote), notice: flash_message(@freight_quote, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize_acl @freight_request
  end

  def update
    filtered_params = freight_quote_params.except(:purchase_order)
    @freight_quote.assign_attributes(filtered_params.merge(overseer: current_overseer))
    authorize_acl @freight_request

    if @freight_quote.valid?
      ActiveRecord::Base.transaction do
        if @freight_quote.status_changed?
          @freight_quote_comment = FreightQuoteComment.new(message: "Status Changed: #{@freight_quote.status}", freight_quote: @freight_quote, overseer: current_overseer)
          @freight_quote.save!
          @freight_quote_comment.save!
        else
          @freight_quote.save!
        end
      end

      redirect_to overseers_freight_request_freight_quote_path(@freight_request, @freight_quote), notice: flash_message(@freight_quote, action_name)
    else
      render 'edit'
    end
  end

  private

    def freight_quote_params
      params.require(:freight_quote).permit!
    end

    def set_freight_quote
      @freight_quote = FreightQuote.find(params[:id])
    end
end
