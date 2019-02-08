# frozen_string_literal: true

json.results(@measurements_units) do |mu|
  json.set! :id, mu.id
  json.set! :text, mu.to_s
end

json.pagination do
  json.set! :more, !@measurement_units.last_page?
end
