json.data (@contacts) do |contact|
  json.array! [

                  [
                      if policy(contact).show?
                        row_action_button(overseers_contact_path(contact), 'fal fa-eye', 'View Contact', 'dark')
                      end,
                      if policy(contact).edit?
                        row_action_button(edit_overseers_contact_path(contact), 'pencil', 'Edit Contact', 'warning')
                      end,
                  ].join(' '),
                  contact.full_name || contact.name,
                  contact.email,
                  contact.account.name,
                  contact.inquiries.size,
                  format_boolean_label(contact.synced?, 'synced'),
                  format_date(contact.created_at)
              ]
end

json.recordsTotal @contacts.model.all.count
json.recordsFiltered @contacts.total_count
json.draw params[:draw]