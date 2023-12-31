class Overseers::Products::CommentsController < Overseers::Products::BaseController
  before_action :set_notification, only: [:create]

  def index
    @comments = @product.comments.earliest
    @new_comment = @product.comments.build
    authorize_acl @comments
  end

  def create
    @comment = @product.comments.build(product_comment_params.merge(overseer: current_overseer))
    authorize_acl @comment

    if @comment.save!
      callback_method = %w(approve reject merge).detect { |action| params[action] }
      send(callback_method) if callback_method.present? && policy(@product).send([callback_method, '?'].join)
      app_send_by = @product.inquiry_import_row.present? ? (InquiryImport.find(@product.inquiry_import_row.inquiry_import_id).created_by) : @product.created_by
      if app_send_by.present?
        @notification.send_product_comment(
          app_send_by,
            action_name.to_sym,
            @product,
            overseers_product_comments_path(@product),
            callback_method, @product.to_s, @comment.message
        )
        if (['approve', 'reject'].include? callback_method) && app_send_by.parent.present?
          @notification.send_product_comment_to_manager(
            app_send_by.parent,
              action_name.to_sym,
              @product,
              overseers_product_comments_path(@product),
              callback_method, @product.to_s, @comment.message, app_send_by
          )
        end
      end
      redirect_to overseers_product_comments_path(@product), notice: flash_message(@comment, action_name)
    else
      render 'new'
    end
  end


  private
    def product_comment_params
      params.require(:product_comment).permit(
        :message,
        :merge_with_product_id
      )
    end

    def approve
      ActiveRecord::Base.transaction do
        @product.create_approval(comment: @comment, overseer: current_overseer)
        @product.save_and_sync
      end
    end

    def reject
      ActiveRecord::Base.transaction do
        @product.create_rejection(comment: @comment, overseer: current_overseer)
        @product.update_attributes(trashed_sku: @product.sku, sku: nil)
      end
    end

    def merge
      merge_with_product = Product.find(@comment.merge_with_product_id)
      product_being_replaced = @product

      ActiveRecord::Base.transaction do
        product_being_replaced.inquiry_products.each do |inquiry_product|
          if inquiry_product.inquiry.products.include? merge_with_product
            inquiry_product.destroy!
          else
            inquiry_product.update_attributes(product: merge_with_product)
          end
        end

        product_being_replaced.comments.reload.each do |comment|
          comment.update_attributes(
            product: merge_with_product,
            merged_product_name: product_being_replaced.name,
            merged_product_sku: product_being_replaced.sku,
            merged_product_metadata: product_being_replaced.to_json
          )
        end
      end

      product_being_replaced.reload.destroy!
      @product = merge_with_product
    end
end
