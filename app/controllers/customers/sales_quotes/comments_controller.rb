# frozen_string_literal: true

class Customers::SalesQuotes::CommentsController < Customers::SalesQuotes::BaseController
  def index
    @comments = @sales_quote.comments
    authorize @comments
  end

  def create
    @comment = @inquiry.comments.build(comment_params.merge(contact: current_contact, show_to_customer: true))
    authorize @comment

    if @comment.save
      redirect_to customers_quote_path(@sales_quote), notice: flash_message(@comment, action_name)
    else
      render "new"
    end
  end

  private

    def comment_params
      params.require(:inquiry_comment).permit(
        :message
      )
    end
end
