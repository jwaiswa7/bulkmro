class Overseers::Inquiries::BaseController < Overseers::BaseController
  before_action :set_inquiry

  private

    def set_inquiry
      @inquiry = Inquiry.find(params[:inquiry_id])
    end

    def render_pdf_for(record, locals={})
      render(
        pdf: record.filename,
        template: ['shared', 'layouts', 'pdf_templates', record.class.name.pluralize.underscore, 'show'].join('/'),
        layout: 'shared/layouts/pdf_templates/show',
        page_size: 'A4',
        footer: {
            center: '[page] of [topage]',
            font_size: 9
        },
        locals: {
            record: record
        }.merge(locals),
        zoom: 0.78125
      )
    end
end
