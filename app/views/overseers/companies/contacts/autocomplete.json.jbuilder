json.results(@contacts) do |contact|
  json.set! :id, contact.id
  json.set! :text, contact.to_s
end

json.pagination do
  json.set! :more, !@contacts.last_page?
end
