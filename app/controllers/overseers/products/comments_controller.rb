class Overseers::Products::CommentsController < Overseers::Products::BaseController
  def index
    @comments = @product.comments


    @new_comment = @product.comments.build

    @new_comment.assign_attributes(:merge_product => 0)
    authorize @comments
  end

  def create
    @comment = @product.comments.build(product_comment_params.merge(:overseer => current_overseer))

    authorize @comment

    if @comment.save
      callback_method = %w(approve reject merge).detect {|action| params[action]}
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

  def merge

    @merge_product = Product.find(params.require(:product_comment).require(:merge_product))

    @comment.message

    ProductComment.create(
        {
            message: @comment.message + " ( Merged Product : #{@product} )",
            product: @merge_product,
            overseer: current_overseer
        }
    )

    @comment.message = @comment.message + +" ( Rejected & Merged Into Product : #{@merge_product} )"

    if !@product.inquiry_products.blank?
      @product.inquiry_products.each do |inquiry_product|
        if !inquiry_product.inquiry.products.include? @merge_product
          inquiry_product.product = @merge_product
          inquiry_product.save
        else
          inquiry_product.destroy!
        end
      end
    end

    @product.destroy!
    @product = @merge_product
    
  end
end