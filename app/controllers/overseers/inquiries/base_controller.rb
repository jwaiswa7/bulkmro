# frozen_string_literal: true

class Overseers::Inquiries::BaseController < Overseers::BaseController
  before_action :set_inquiry

  private

    def set_inquiry
      @inquiry = Inquiry.find(params[:inquiry_id])
    end

    def render_pdf_for(record, locals={})
      render(
        pdf: record.filename,
        template: ["shared", "layouts", "pdf_templates", record.class.name.pluralize.underscore, "show"].join("/"),
        layout: "shared/layouts/pdf_templates/show",
        page_size: "A4",
        footer: {
            center: "[page] of [topage]"
        },
        # show_as_html: true,
        locals: {
            record: record
        }.merge(locals)
      )
    end
end
