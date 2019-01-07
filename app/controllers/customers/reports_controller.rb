class Customers::ReportsController < Customers::BaseController
  def index
    authorize :report, :show?

    service = ['Services', 'Customers', 'Charts', params['graph'].camelize].join('::').constantize.send(:new, (params['daterange'].present? ? params['daterange'] : nil))
    @chart = service.call(current_company)

    render params['graph']
  end
end