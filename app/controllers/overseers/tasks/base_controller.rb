# frozen_string_literal: true

class Overseers::Tasks::BaseController < Overseers::BaseController
  before_action :set_task

  private

    def set_task
      @task = Task.find(params[:task_id])
    end
end
