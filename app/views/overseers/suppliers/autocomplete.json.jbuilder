# frozen_string_literal: true

json.results(@suppliers) do |supplier|
  json.set! :id, supplier.id
  json.set! :text, supplier.to_s
end

json.pagination do
  json.set! :more, !@suppliers.last_page?
end
