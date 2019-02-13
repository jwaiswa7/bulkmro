

class Services::Overseers::RequestCronJobs::RemoveRequestCronJob < Services::Shared::BaseService
  def call
    delete_unwanted_request(CallbackRequest.order("updated_at"))
    delete_unwanted_request(RemoteRequest.order("updated_at"))
  end

  def delete_unwanted_request(request_type, count: 5000)
    if request_type.present? && request_type.count > count
      request_type.limit(request_type.count - count).delete_all
    else
      puts "false"
    end
  end
end
