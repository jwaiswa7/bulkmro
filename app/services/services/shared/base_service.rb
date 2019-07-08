class Services::Shared::BaseService
  include DisplayHelper

  def routes
    Rails.application.routes.url_helpers
  end

  def helpers
    ActionController::Base.helpers
  end

  def perform_later(*args)
    if Rails.env.production? || Rails.env.staging?
      ApplicationJob.perform_later(self.class.name, *args)
    else
      ApplicationJob.perform_now(self.class.name, *args)
    end
  end

  def perform_export_later(*args)
    if Rails.env.production? || Rails.env.staging?
      ApplicationExportJob.perform_now(*args)
    else
      ApplicationExportJob.perform_now(*args)
    end
  end
end
