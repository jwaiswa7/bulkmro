# frozen_string_literal: true

json.results(@kits) do |kit|
  json.set! :id, kit.id
  json.set! :text, kit.to_s
end

json.pagination do
  json.set! :more, !@kits.last_page?
end
