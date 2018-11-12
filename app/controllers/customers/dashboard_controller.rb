class Customers::DashboardController < Customers::BaseController

  def show
    @contact = current_contact
    @account = contact.account


    @products = Inquiry.joins(:inquiry_products).where(:company => @contact.companies)

    @products_count = @products.top(:product_id).size
    @sales_quotes = SalesQuote.joins(:inquiry).where('inquiries.company_id in (?)',@contact.company_ids).where('inquiries.status not in (?)', Inquiry.statuses[:'Order Lost']).where.not(:sent_at => nil).distinct(:inquiry_id).latest.uniq {|p| p.inquiry_id}
    @sales_orders = SalesOrder.joins(:inquiry,:company).where('inquiries.company_id in (?)',@contact.company_ids).where.not(:order_number => nil).not_rejected.latest

    @sales_quotes_count = @sales_quotes.count
    @sales_orders_count = @sales_orders.count

    @recent_sales_quotes = @sales_quotes.first(5)
    @recent_sales_orders = @sales_orders.first(5)

    @most_ordered_products = @products.top(:product_id,5).map {|id, c| [Product.find(id), [c,'times'].join(' ')]}
  end


  attr_accessor :contact, :account
end