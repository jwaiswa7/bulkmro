class Overseers::ExportsController < Overseers::BaseController
  def index
    authorize_acl :export
    @export_filtered = {}
    @exports_all = Export.where(status: ['Completed','Processing']).order('created_at asc').group_by(&:export_type).except(nil)
    @exports_all.each do |export_type,export_val|
      export_val_filtered = {}
      export_val.reverse.each do |exp|
        if !(export_val_filtered.key?(exp.status))
          if exp.status.include?('Completed') && exp.report.attached?
            export_val_filtered['Completed'] = exp
          elsif exp.status.include?('Processing')
            export_val_filtered['Processing'] = exp
          end
          break if (export_val_filtered.keys.include?("Completed") && export_val_filtered.keys.include?("Processing"))
        end
      end
      @export_filtered[export_type] = export_val_filtered
    end
  end


  def generate_export
    authorize_acl :export

    service = ['Services', 'Overseers', 'Exporters', (params['export_type'].parameterize(separator: '_') + '_exporter').classify].join('::').constantize.new
    service.call
    redirect_to overseers_exports_path, notice: set_flash_message('Export started', 'success')
  end
end
