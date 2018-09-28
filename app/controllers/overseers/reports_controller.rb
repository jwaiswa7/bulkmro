class Overseers::ReportsController < Overseers::BaseController

  def index
    @reports =  ApplyDatatableParams.to(Report.all, params)
    authorize @reports
  end

  def show
    @report = Report.find_by_uid(params[:id])
    @report.assign_attributes(report_params)
    service = Services::Overseers::Reports::Preprocessor.new(@report)
    service.call

    authorize @report

    send @report.uid
    render @report.uid
  end

  private
  def activity_report
    @activities = Activity.all.where(:created_at => @report.start_at..@report.end_at)
  end

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