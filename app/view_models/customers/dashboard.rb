class Customers::Dashboard
  def initialize(contact)
    @contact = contact
    @account = contact.account
  end
  
  def record
    if contact.account_manager?
      account
    else
      contact
    end
  end

  attr_reader :contact, :account
end