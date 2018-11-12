class Customers::Dashboard
  def initialize(contact)
    @contact = contact
    @account = contact.account
  end

  def products(top: nil)
    Inquiry.joins(:inquiry_products).where(:company => contact.companies).top(:product_id, top) # nil top returns all
  end

  def sales_orders
    SalesOrder.joins(:inquiry, :company).where('inquiries.company_id in (?)', contact.company_ids).where.not(:order_number => nil).not_rejected.latest
  end

  def sales_quotes
    SalesQuote.joins(:inquiry).where('inquiries.company_id in (?)', contact.company_ids).where('inquiries.status not in (?)', Inquiry.statuses[:'Order Lost']).where.not(:sent_at => nil).distinct(:inquiry_id).latest.uniq {|p| p.inquiry_id}
  end

  def recent_sales_quotes
    sales_quotes.first(5)
  end

  def recent_sales_orders
    sales_orders.first(5)
  end

  def most_ordered_products
    products(top: 5).map {|id, c| [Product.find(id), [c, 'times'].join(' ')]}
  end

  attr_reader :contact, :account
end