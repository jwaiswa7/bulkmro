class Overseers::Products::CommentsController < Overseers::Products::BaseController
  def new
    @comment = @product.comments.build(:overseer => current_overseer)
    authorize @comment
  end

  def create
    @comment = @product.comments.build(product_comment_params.merge(:overseer => current_overseer))

    authorize @comment

    if @comment.save
      callback_method = %w(approve disapprove reject).detect { |action| params[action] }
      send(callback_method) if callback_method.present? && policy(@product).send([callback_method, '?'].join)

      redirect_to new_overseers_product_comment_path(@product), notice: flash_message(@comment, action_name)
    else
      render 'new'
    end
  end


  private
  def product_comment_params
    params.require(:product_comment).permit(
        :message
    )
  end

  def approve
    @product.create_approval(:comment => @comment, :overseer => current_overseer)
  end

  def disapprove
    raise
  end

  def reject
    @product.update_attributes(:trashed_uid => @product.sku, :sku => nil)
  end
end