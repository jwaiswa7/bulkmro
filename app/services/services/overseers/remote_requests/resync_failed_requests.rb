

class Services::Overseers::RemoteRequests::ResyncFailedRequests < Services::Shared::BaseService
  def initialize
    @start_at = Date.today.beginning_of_day
    @end_at = Date.today.end_of_day
  end

  def call
    requests = RemoteRequest.where(created_at: start_at..end_at).failed
    requested = []
    requests.each do |request|
      new_request = [request.subject_type, request.subject_id].join("-")
      if !requested.include? new_request
        if request.subject_type.present? && request.subject_id.present?
          begin
            Object.const_get(request.subject_type).find(request.subject_id).save_and_sync
            requested << new_request
          rescue
            puts request
          end
        end
      end
    end
    [requested.sort, requested.size]
  end

  attr_accessor :start_at, :end_at
end
