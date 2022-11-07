class Customers::WishListPolicy < Customers::ApplicationPolicy
  def show?
    vertiv? 
  end

  def add_item?
    true
  end

  private
	def vertiv? 
		true # contact.account_id == 2478
	end
end
