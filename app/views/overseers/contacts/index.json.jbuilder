json.data (@contacts) do |contact|
  json.array! [

                  [
                      if policy(contact).show?
                        row_action_button(overseers_contact_path(contact), 'fal fa-eye', 'View Contact', 'info')
                      end,
                      if policy(contact).edit?
                        row_action_button(edit_overseers_contact_path(contact), 'pencil', 'Edit Contact', 'warning')
                      end,
                      row_action_button(login_as_contact_overseers_contacts_path(contact_id: contact.id), 'fal fa-sign-in', 'Sign in as Contact', 'dark', '_blank'),
                      if contact.company.present? && policy(contact.company).new_inquiry?
                        row_action_button(new_overseers_inquiry_path(company_id: contact.company.to_param), 'plus-circle', 'New Inquiry', 'success')
                      end,
                  ].join(' '),
                  contact.name,
                  contact.email,
                  contact.account.name,
                  contact.inquiries.size,
                  format_date(contact.created_at)
              ]
end

json.recordsTotal @contacts.model.all.count
json.recordsFiltered @indexed_contacts.total_count
json.draw params[:draw]