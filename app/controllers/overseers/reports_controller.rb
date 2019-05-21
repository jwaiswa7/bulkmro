class Overseers::ReportsController < Overseers::BaseController
  def index
    Report.activity
    Report.target
    Report.monthly_sales
    Report.inward_logistic_queue

    @reports = ApplyDatatableParams.to(Report.all, params)
    authorize @reports
  end

  def show
    @report = Report.find_by_uid(params[:id])
    @report.assign_attributes(report_params)
    params[:overseer] = current_overseer
    # @report.designation = 'Inside'
    service = ['Services', 'Overseers', 'Reports', @report.name].join('::').constantize.send(:new, @report, params)
    @data = service.call

    authorize @report

    render @report.uid
  end

  def export_report
     # binding.pry
    @report = Report.find_by_uid(params[:id])
    @report.assign_attributes(report_params)
    params[:overseer] = current_overseer
    service = ['Services', 'Overseers', 'Reports', @report.name].join('::').constantize.send(:new, @report, params)
    @indexed_records = service.call
    # binding.pry
    authorize @report
    export_service = Services::Overseers::Exporters::MonthlySalesReportsExporter.new([], current_overseer, @indexed_records, params[:id])
    export_service.call
    # export_service = ['Services', 'Overseers', 'Exports', @report.name].join('::').constantize.send(:new, @indexed_records, params)
    # export_service.call
    redirect_to url_for(Export.monthly_sales_report.not_filtered.last.report)
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
