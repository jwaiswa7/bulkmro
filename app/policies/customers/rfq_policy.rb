class Customers::RfqPolicy < Customers::ApplicationPolicy
	def index?
    bombardier? 
	end

	def new?
		bombardier? 
	end

	def create?
		bombardier? 
	end

	def show?
		bombardier? 
	end

	private

	def bombardier? 
		contact.account_id == 2208
	end
end
