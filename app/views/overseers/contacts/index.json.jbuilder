json.data (@contacts) do |contact|
  json.array! [

                  [
                      if is_authorized(contact, 'show') && policy(contact).show?
                        row_action_button(overseers_contact_path(contact), 'fal fa-eye', 'View Contact', 'info', :_blank)
                      end,
                      if is_authorized(contact, 'edit') && policy(contact).edit?
                        row_action_button(edit_overseers_contact_path(contact), 'pencil', 'Edit Contact', 'warning', :_blank)
                      end,
                      if is_authorized(contact, 'become') && policy(contact).become?
                        row_action_button(become_overseers_contact_path(contact), 'fal fa-sign-in', 'Sign in as Contact', 'dark', :_blank)
                      end,
                      if contact.company.present? && is_authorized(:inquiry, 'new')
                        row_action_button(new_overseers_inquiry_path(company_id: contact.company.to_param), 'plus-circle', 'New Inquiry', 'success', :_blank)
                      end,
                  ].join(' '),
                  conditional_link(contact.name, overseers_contact_path(contact), is_authorized(contact, 'show')),
                  contact.email,
                  link_to(contact.account.name, overseers_account_path(contact.account), target: '_blank'),
                  contact.role.titleize,
                  contact.inquiries.size,
                  format_succinct_date(contact.created_at)
              ]
end

json.recordsTotal @contacts.model.all.count
json.recordsFiltered @contacts.total_count
json.draw params[:draw]
