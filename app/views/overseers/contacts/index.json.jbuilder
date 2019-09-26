json.data (@contacts) do |contact|
  json.array! [

                  [
                      if is_authorized(contact, 'show') && policy(contact).show?
                        row_action_button_without_fa(overseers_contact_path(contact), 'bmro-icon-table bmro-icon-used-view', 'View Contact', 'info', :_blank)
                      end,
                      if is_authorized(contact, 'edit') && policy(contact).edit?
                        row_action_button_without_fa(edit_overseers_contact_path(contact), 'bmro-icon-table bmro-icon-pencil', 'Edit Contact', 'warning', :_blank)
                      end,
                      if is_authorized(contact, 'become') && policy(contact).become?
                        row_action_button_without_fa(become_overseers_contact_path(contact), 'bmro-icon-table bmro-icon-signin', 'Sign in as Contact', 'dark', :_blank)
                      end,
                      if is_authorized(contact.company, 'new_inquiry') && policy(contact.company).new_inquiry?
                        row_action_button_without_fa(new_overseers_inquiry_path(company_id: contact.company.to_param), 'bmro-icon-table bmro-icon-sighnature-plus', 'New Inquiry', 'success', :_blank)
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
