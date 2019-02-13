

json.results(@categories) do |category|
  json.set! :id, category[:id]
  json.set! :text, category[:text]
end
