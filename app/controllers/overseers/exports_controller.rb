class Overseers::ExportsController < Overseers::BaseController
  def index
    authorize_acl :export

    @exports_all = Export.order('created_at asc').group_by(&:export_type).except(nil)
  end


  def generate_export
    authorize_acl :export

    service = ['Services', 'Overseers', 'Exporters', (params['export_type'].parameterize(separator: '_') + '_exporter').classify].join('::').constantize.new
    service.call
    redirect_to overseers_exports_path, notice: set_flash_message('Export started', 'success')
  end
end
