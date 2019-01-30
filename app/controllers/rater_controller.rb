class RaterController < ApplicationController

  def create
      obj = params[:klass].classify.constantize.find(params[:id])
      obj.rate params[:score].to_f, current_overseer, params[:dimension]
      obj.update(rating: params[:score].to_f)

      render :json => true
  end
end
