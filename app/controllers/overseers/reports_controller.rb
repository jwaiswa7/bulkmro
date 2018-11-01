class Overseers::ReportsController < Overseers::BaseController

  def index
    Report.activity
    Report.pipeline
    Report.target
    @reports = ApplyDatatableParams.to(Report.all, params)
    authorize @reports
  end

  def show
    @report = Report.find_by_uid(params[:id])
    @report.assign_attributes(report_params)
    service = ['Services', 'Overseers', 'Reports', @report.name].join('::').constantize.send(:new, @report)
    @data = service.call

    authorize @report

    render @report.uid
  end

  private

  def report_params
    if params.has_key?(:report)
      params.require(:report).permit(
          :date_range,
          :start_at,
          :end_at
      )
    else
      {}
    end
  end
end