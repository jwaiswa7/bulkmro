json.data (@contacts) do |contact|
  json.array! [
                 
                  contact.full_name,
                  contact.companies.size,
                  format_date(contact.created_at)
              ]
end

json.recordsTotal @contacts.model.all.count
json.recordsFiltered @contacts.total_count
json.draw params[:draw]