

class Customers::Inquiries::BaseController < Customers::BaseController
  before_action :set_inquiry

  private

    def set_inquiry
      @inquiry = Inquiry.find(params[:inquiry_id])
    end

    def render_pdf_for(record)
      render(
        pdf: record.filename,
        template: ['shared', 'layouts', 'pdf_templates', record.class.name.pluralize.underscore, 'show'].join('/'),
        layout: 'shared/layouts/pdf_templates/show',
        page_size: 'Legal',
        footer: {
            center: '[page] of [topage]'
        },
        locals: {
            record: record
        }
      )
    end
end
