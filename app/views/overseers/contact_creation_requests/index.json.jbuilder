json.data (@contact_creation_requests) do |contact|
  json.array! [
                  [
                    if !contact.contact.present? && is_authorized(:contact, 'new') && contact.activity.company_id.present?
                     row_action_button_without_fa(new_overseers_contact_path(ccr_id: contact.id), 'bmro-icon-table bmro-icon-new-contact', 'New Contact', 'success', :_blank)
                    end,
                    if is_authorized(contact, 'show')
                      row_action_button_without_fa(overseers_contact_creation_request_path(contact), 'bmro-icon-table bmro-icon-used-view',  'View Contact Creation Request', 'info', :_blank)
                    end,
                    if is_authorized(contact.activity, 'show')
                      row_action_button_without_fa(edit_overseers_activity_path(contact.activity), 'bmro-icon-table bmro-icon-pencil',  'Edit Activity', 'warning', :_blank)
                    end
                  ].join(' '),
                    link_to(contact.first_name, overseers_contact_creation_request_path(contact), target: '_blank'),
                    contact.last_name,
                    contact.email,
                    contact.telephone.present? ? contact.telephone : '--',
                    contact.mobile.present? ? contact.mobile : '--',
                    format_succinct_date(contact.created_at)
                  ]
end
json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @contact_creation_requests.model.all.count
json.recordsFiltered @contact_creation_requests.total_count
json.draw params[:draw]
