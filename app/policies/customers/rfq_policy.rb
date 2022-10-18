class Customers::RfqPolicy < Customers::ApplicationPolicy
	def index?
    	bombardier? || vertiv? 
	end

	def new?
		bombardier? || vertiv? 
	end

	def create?
		bombardier? || vertiv? 
	end

	def show?
		bombardier? || vertiv? 
	end

	private

	def bombardier? 
		contact.account_id == 2208
	end

	def vertiv? 
		contact.account_id == 2478
	end
end
