class Customers::SalesQuotes::BaseController < Customers::BaseController
  before_action :set_sales_quote

  private

  def set_sales_quote
    @sales_quote = SalesQuote.find(params[:id])
    @inquiry = @sales_quote.inquiry
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
