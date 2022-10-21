class Overseers::Activities::BaseController < Overseers::BaseController
  before_action :activity

  private
    def activity
      @activity = Activity.find(params[:activity_id])
    end
end
