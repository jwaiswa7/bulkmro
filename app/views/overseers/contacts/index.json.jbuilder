json.data (@contacts) do |contact|
  json.array! [

                  [
                      if policy(contact).edit?
                        row_action_button(edit_overseers_contact_path(contact), 'pencil', 'Edit Inquiry', 'warning')
                      end,
                  ].join(' '),
                  contact.full_name,
                  contact.companies.size,
                  format_date(contact.created_at)
              ]
end

json.recordsTotal @contacts.model.all.count
json.recordsFiltered @contacts.total_count
json.draw params[:draw]