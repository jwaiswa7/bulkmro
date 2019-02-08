# frozen_string_literal: true

json.results(@categories) do |category|
  json.set! :id, category.id
  json.set! :text, category.to_s
end

json.pagination do
  json.set! :more, !@categories.last_page?
end
