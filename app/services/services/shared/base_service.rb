class Services::Shared::BaseService
	include DisplayHelper

	def routes
		Rails.application.routes.url_helpers
	end

	def helpers
		ActionController::Base.helpers
	end

  def perform_later(*args)
		ApplicationJob.perform_now(self.class.name, *args)
	end
end