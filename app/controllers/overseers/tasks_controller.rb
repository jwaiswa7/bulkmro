class Overseers::TasksController < Overseers::BaseController
  before_action :set_task, only: [:edit, :update, :show]


  def index
    service = Services::Overseers::Finders::Tasks.new(params, current_overseer)
    service.call
    @indexed_tasks = service.indexed_records
    @tasks = service.records
    # authorize_acl @tasks
  end


  def new
    @task = Task.new(overseer: current_overseer)
    # authorize_acl @task
  end


  def create
    @task = Task.new(task_params.merge(overseer: current_overseer))
    # authorize_acl @task
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
    # authorize_acl @task

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
      overseer_ids: [],
      attachments: []
    )
  end
end
