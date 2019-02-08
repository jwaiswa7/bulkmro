# frozen_string_literal: true

class Overseers::Products::BaseController < Overseers::BaseController
  before_action :set_product

  private
    def set_product
      @product = Product.find(params[:product_id])
    end
end
