class Overseers::TasksController < Overseers::BaseController
  before_action :set_task, only: [:edit, :update, :show]

  def index
    service = Services::Overseers::Finders::Tasks.new(params)
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
      redirect_to overseers_tasks_path, notice: flash_message(@task, action_name)
    else
      render 'new'
    end
  end

  def update
    @task.assign_attributes(task_params.merge(overseer: current_overseer))
    authorize_acl @task
    if @task.save
      redirect_to overseers_tasks_path, notice: flash_message(@task, action_name)
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
      overseer_ids: [],
      attachments: []
    )
  end
end

