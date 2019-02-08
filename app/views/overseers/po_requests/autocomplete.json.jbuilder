# frozen_string_literal: true

json.results(@po_requests) do |kit|
  json.set! :id, kit.id
  json.set! :text, kit.to_s
end

json.pagination do
  json.set! :more, !@po_requests.last_page?
end
