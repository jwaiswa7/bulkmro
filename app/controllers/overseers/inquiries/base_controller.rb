class Overseers::Inquiries::BaseController < Overseers::BaseController
  before_action :set_inquiry

  private

  def set_inquiry
    @inquiry = Inquiry.find(params[:inquiry_id])
  end

  # def check_smtp
  #   if !GmailSmtp.exists?(email: current_overseer.email) || !GmailSmtp.where(:email => current_overseer.email).first.password.present?
  #       flash[:error] = "Your SMTP is not Valid. Email will not be sent. Please contact web admin"
  #   end
  # end
  #

  def render_pdf_for(record)
    render(
        pdf: record.filename,
        template: ['overseers', 'inquiries', record.class.name.pluralize.underscore, 'show'].join('/'),
        layout: 'overseers/inquiries/layouts/show',
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
