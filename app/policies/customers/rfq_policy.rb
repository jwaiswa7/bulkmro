class Customers::RfqPolicy < Customers::ApplicationPolicy
	def index?
		contact.account_id == 2208
	end
end
