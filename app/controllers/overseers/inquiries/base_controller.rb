class Overseers::Inquiries::BaseController < Overseers::BaseController
  before_action :set_inquiry

  private

  def set_inquiry
    @inquiry = Inquiry.find(params[:inquiry_id])
  end

  def render_pdf_for(record)
    render(
        pdf: record.filename,
        template: ['overseers', 'inquiries', record.class.name.pluralize.underscore, 'show'].join('/'),
        layout: 'overseers/inquiries/layouts/show',
        page_size: 'A4',
        footer: {
            center: '[page] of [topage]'
        },
        locals: {
            record: record
        }
    )
  end
end
