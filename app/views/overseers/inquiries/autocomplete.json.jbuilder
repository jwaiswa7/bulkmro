json.results(@inquiries.reverse) do |inquiry|
  json.set! :id, (@encoded == "true") ? Inquiry.encode_id(inquiry.id) : inquiry.id
  json.set! :text, inquiry.to_s
end

json.pagination do
  json.set! :more, !@indexed_inquiries.last_page?
end
