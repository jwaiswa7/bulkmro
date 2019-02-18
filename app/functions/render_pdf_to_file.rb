class RenderPdfToFile < BaseFunction
  def self.for(record, locals={})
    action_view = ActionView::Base.new(ActionController::Base.view_paths, {})
    action_view.class.send(:include, DisplayHelper)

    pdf_string = WickedPdf.new.pdf_from_string(
      action_view.render(
        template: ['shared', 'layouts', 'pdf_templates', record.class.name.pluralize.underscore, 'show'].join('/'),
        locals: {
            record: record,
        }.merge(locals),
        layout: 'shared/layouts/pdf_templates/show',
      ),
        pdf: record.filename,
        layout: false,
        footer: {
            center: '[page] of [topage]'
        },
    )

    tempfile = Tempfile.new([record.filename, 'pdf'].join('.'), Rails.root.join('tmp'))
    tempfile.binmode
    tempfile.write pdf_string
    tempfile.close

    tempfile.path
  end
end
