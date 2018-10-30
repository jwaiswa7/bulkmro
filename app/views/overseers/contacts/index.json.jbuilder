json.data (@contacts) do |contact|
  json.array! [

                  [
                      if policy(contact).show?
                        row_action_button(overseers_contact_path(contact), 'fal fa-eye', 'View Contact', 'info')
                      end,
                      if policy(contact).edit?
                        row_action_button(edit_overseers_contact_path(contact), 'pencil', 'Edit Contact', 'warning')
                      end,
                      if contact.company.present? && policy(contact.company).new_inquiry?
                        row_action_button(new_overseers_inquiry_path(company_id: contact.company.to_param), 'plus-circle', 'New Inquiry', 'success')
                      end,
                  ].join(' '),
                  contact.full_name,
                  contact.email,
                  contact.account.name,
                  contact.inquiries.size,
=begin
                  format_boolean_label(contact.synced?, 'synced'),
=end
                  format_date(contact.created_at)
              ]
end

json.recordsTotal @contacts.model.all.count
json.recordsFiltered @contacts.total_count
json.draw params[:draw]