class Services::Shared::BaseService
	include DisplayHelper

	def routes
		Rails.application.routes.url_helpers
	end

	def helpers
		ActionController::Base.helpers
	end
end