class Customers::AddressPolicy < Customers::ApplicationPolicy
	def autocomplete?
    	true 
	end
end
