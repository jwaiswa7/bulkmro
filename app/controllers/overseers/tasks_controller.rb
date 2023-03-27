class Overseers::TasksController < Overseers::BaseController
  before_action :set_task, only: [:edit, :update, :show, :render_comment_form, :render_modal_form, :add_comment]


  def index
    service = Services::Overseers::Finders::Tasks.new(params, current_overseer)
    service.call
    @indexed_tasks = service.indexed_records
    @tasks = service.records
    authorize_acl @tasks
end


  def new
    @task = Task.new(overseer: current_overseer)
    authorize_acl @task
  end


  def create
    @task = Task.new(task_params.merge(overseer: current_overseer))
    authorize_acl @task
    if @task.save
      t_number = Services::Resources::Shared::UidGenerator.generate_task_number(@task.id)
      @task.update_attributes(task_id: t_number)

      Services::Overseers::Tasks::SendEmailAtCreation.new(@task, current_overseer).call
      redirect_to overseers_tasks_path, notice: flash_message(@task, action_name)
    else
      render 'new'
    end
  end

  def show
    authorize_acl @task
  end


  def update
    authorize_acl @task

    @task.assign_attributes(task_params.merge(overseer: current_overseer))
    if @task.valid?
      if @task.status_changed?
        @email_message = @task.email_messages.build(task: @task ,overseer: Overseer.system_overseer)
        @task.overseers.each do |assignee|
          @email_message.assign_attributes(
          to: assignee.email,
          subject: "Status of the Task is Changed",
          body: TaskMailer.email_task_creation(@email_message , assignee).body.raw_source,
          )
          if @email_message.save
            service = Services::Shared::EmailMessages::BaseService.new()
            service.send_email_message_with_sendgrid(@email_message)
          end
        end
      end

      if @task.due_date_changed?
        @email_message = @task.email_messages.build(task: @task ,overseer: Overseer.system_overseer)
        tos = @task.overseers.pluck(:email)
        tos << @task.created_by.email
        tos.each do |to|
          @email_message.assign_attributes(
          to: to,
          subject: "Due Date of the Task is Changed",
          body: TaskMailer.email_task_creation(@email_message , Overseer.find_by_email(to)).body.raw_source,
          )
          if @email_message.save
            service = Services::Shared::EmailMessages::BaseService.new()
            service.send_email_message_with_sendgrid(@email_message)
          end
        end
      end

      @task.save!
      redirect_to overseers_tasks_path, notice: flash_message(@task, action_name)
    else
      render 'edit'
    end
  end

  def render_modal_form
    authorize_acl @task
    respond_to do |format|
      if params[:title] == 'Comment'
        format.html {render partial: 'overseers/tasks/add_comment', locals: {obj: @task, url: add_comment_overseers_task_path(@task), view_more: overseers_task_path(@task)}}
      else
        ""
      end
    end
  end

  def add_comment
    @task.assign_attributes(task.merge(overseer: current_overseer))
    authorize_acl @task
    @task.skip_grpo_number_validation = true
    if @task.valid?
      if params['task']['comments_attributes']['0']['message'].present?
        ActiveRecord::Base.transaction do
          @task.save!
          @task_comment = TaskComment.new(message: '', task: @task, overseer: current_overseer)
        end
        render json: {success: 1, message: 'Successfully updated '}, status: 200
      else
        render json: {error: {base: 'Field cannot be blank!'}}, status: 500
      end
    else
      ""
    end
  end


  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :task_id,
      :subject,
      :status,
      :priority,
      :description,
      :company_id,
      :department,
      :created_by,
      :due_date,
      :created_at,
      :comments,
      :message,
      comments_attributes: [:id, :message, :created_by_id, :updated_by_id],
      overseer_ids: [],
      attachments: []
    )
  end
end
