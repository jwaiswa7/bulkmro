class Overseers::Tasks::CommentsController < Overseers::Tasks::BaseController
  before_action :set_notification, only: [:create]

  def index
    @comments = @task.comments.earliest
    @new_comment = @task.comments.build
    authorize_acl @task
  end

  def create
    @comment = @task.comments.build(task_comment_params.merge(overseer: current_overseer))
    @comment.assign_attributes(message: "[#{@comment.tag_user.full_name}] #{task_comment_params[:message]}")
    authorize_acl @task
    if @comment.save && @comment.tag_user.present?
        @notification.send_task_comment(
          @comment.tag_user_id,
          action_name.to_sym,
          @comment,
          overseers_task_comments_path(@task),
          @comment.message
        )
    end
    redirect_to overseers_task_comments_path(@task), notice: flash_message(@comment, action_name)
  end

  private

    def task_comment_params
      params.require(:task_comment).permit(
        :message,
        :tag_user_id,
        attachments: []
      )
    end
end
