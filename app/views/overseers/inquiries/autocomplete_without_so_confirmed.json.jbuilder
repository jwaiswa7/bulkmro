json.results(@inquiries) do |inquiry|
  json.set! :id, (@encoded == "true") ? Inquiry.encode_id(inquiry.id) : inquiry.id
  json.set! :text, inquiry.to_s
end

json.pagination do
  json.set! :more, true
end
