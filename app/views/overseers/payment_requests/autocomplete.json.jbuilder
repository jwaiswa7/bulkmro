# frozen_string_literal: true

json.results(@payment_requests) do |payment_request|
  json.set! :id, payment_request.id
  json.set! :text, payment_request.to_s
end

json.pagination do
  json.set! :more, !@payment_requests.last_page?
end
