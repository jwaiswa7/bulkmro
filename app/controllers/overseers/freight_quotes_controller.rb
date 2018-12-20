class Overseers::FreightQuotesController < Overseers::BaseController
  before_action :set_freight_quote, only: [:show]

  def index
    freight_quotes =
        if params[:status].present?
          @status = params[:status]
          FreightQuote.where(:status => params[:status])
        else
          FreightQuote.all
        end.order(id: :desc)

    @freight_quotes = ApplyDatatableParams.to(freight_quotes, params)
    authorize @freight_quotes
    render 'overseers/freight_quotes/index'
  end

  def show
    authorize @freight_quote
    render 'overseers/freight_requests/freight_quotes/show'
  end

  private

  def set_freight_quote
    @freight_quote = FreightQuote.find(params[:id])
  end
end
