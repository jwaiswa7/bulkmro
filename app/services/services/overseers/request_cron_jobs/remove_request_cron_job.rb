class Services::Overseers::RequestCronJobs::RemoveRequestCronJob < Services::Shared::BaseService
  def call
    delete_unwanted_request(CallbackRequest.order('updated_at'))
    delete_unwanted_request(RemoteRequest.order('updated_at'))
  end

  def delete_unwanted_request(request_type)
    if request_type.present? && request_type.count > 5000
      request_type.delete(request_type.limit(request_type.count - 5000 ).pluck(:id))
    else
      puts 'false'
    end
  end
end