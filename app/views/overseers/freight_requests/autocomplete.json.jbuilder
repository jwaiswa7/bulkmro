# frozen_string_literal: true

json.results(@freight_requests) do |freight_request|
  json.set! :id, freight_request.id
  json.set! :text, freight_request.to_s
end

json.pagination do
  json.set! :more, !@freight_requests.last_page?
end
