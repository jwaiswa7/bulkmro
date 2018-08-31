class Overseers::Products::CommentsController < Overseers::Products::BaseController
  def index
    @comments = @product.comments
    authorize @comments
  end

  def create
    @comment = @product.comments.build(product_comment_params.merge(:overseer => current_overseer))

    authorize @comment

    if @comment.save
      callback_method = %w(approve reject).detect { |action| params[action] }
      send(callback_method) if callback_method.present? && policy(@product).send([callback_method, '?'].join)

      redirect_to overseers_product_comments_path(@product), notice: flash_message(@comment, action_name)
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

  def reject
    ActiveRecord::Base.transaction do
      @product.create_rejection(:comment => @comment, :overseer => current_overseer)
      @product.update_attributes(:trashed_sku => @product.sku, :sku => nil)
    end
  end
end