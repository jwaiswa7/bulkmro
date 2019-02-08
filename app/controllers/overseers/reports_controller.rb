# frozen_string_literal: true

class Overseers::ReportsController < Overseers::BaseController
  def index
    Report.activity
    Report.target
    Report.monthly_sales

    @reports = ApplyDatatableParams.to(Report.all, params)
    authorize @reports
  end

  def show
    @report = Report.find_by_uid(params[:id])
    @report.assign_attributes(report_params)
    params[:overseer] = current_overseer
    # @report.designation = 'Inside'
    service = ["Services", "Overseers", "Reports", @report.name].join("::").constantize.send(:new, @report, params)
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
            :end_at,
            :filters
        )
      else
        {}
      end
    end
end
