class Callbacks::SalesOrdersController < Callbacks::BaseController

  def create
    service_class = ['Services', 'Callbacks', controller_name.classify.pluralize, 'Create'].join('::').constantize
    service = service_class.new(params)
    render json: service.call, status: :ok
  end

  def update
    service_class = ['Services', 'Callbacks', controller_name.classify.pluralize, 'Update'].join('::').constantize
    service = service_class.new(params)
    render json: service.call, status: :ok
  end

  def render_successful(status = 1, message = 'Request successfully handled', response = nil)
    render json: {success: status, status: status, message: message, response: response}, status: :ok
  end

  def render_unsuccessful(status = 0, message = 'Request unsuccessful', response = nil)
    render json: {success: status, status: status, message: message, response: response}, status: 500
  end

end