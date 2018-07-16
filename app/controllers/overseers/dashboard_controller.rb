class Overseers::DashboardController < Overseers::BaseController
	def show
		authorize :dashboard, :show?
	end
end
