# frozen_string_literal: true

json.results(@accounts) do |company|
  json.set! :id, company.id
  json.set! :text, company.to_s
end

json.pagination do
  json.set! :more, !@accounts.last_page?
end
