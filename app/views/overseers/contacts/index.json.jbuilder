# frozen_string_literal: true

json.data (@contacts) do |contact|
  json.array! [

                  [
                      if policy(contact).show?
                        row_action_button(overseers_contact_path(contact), "fal fa-eye", "View Contact", "info", :_blank)
                      end,
                      if policy(contact).edit?
                        row_action_button(edit_overseers_contact_path(contact), "pencil", "Edit Contact", "warning", :_blank)
                      end,
                      if policy(contact).become?
                        row_action_button(become_overseers_contact_path(contact), "fal fa-sign-in", "Sign in as Contact", "dark", :_blank)
                      end,
                      if contact.company.present? && policy(contact.company).new_inquiry?
                        row_action_button(new_overseers_inquiry_path(company_id: contact.company.to_param), "plus-circle", "New Inquiry", "success", :_blank)
                      end,
                  ].join(" "),
                  conditional_link(contact.name, overseers_contact_path(contact), policy(contact).show?),
                  contact.email,
                  contact.account.name,
                  contact.role.titleize,
                  contact.inquiries.size,
                  format_succinct_date(contact.created_at)
              ]
end

json.recordsTotal @contacts.model.all.count
json.recordsFiltered @contacts.total_count
json.draw params[:draw]
