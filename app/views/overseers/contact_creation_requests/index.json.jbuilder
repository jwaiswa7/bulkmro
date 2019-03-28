json.data (@contact_creation_requests) do |contact|
  json.array! [
  				  [
                if !contact.contact.present? && policy(:contact).new?
                  row_action_button(new_overseers_contact_path(ccr_id: contact.id), 'building', 'New Contact', 'success', :_blank)
                end,
                if policy(contact).show?
                  row_action_button(overseers_contact_creation_request_path(contact), 'eye',  'View Contact Creation Request', 'info', :_blank)
                end,
                if policy(contact.activity).show?
                  row_action_button(edit_overseers_activity_path(contact.activity), 'pencil',  'Edit Activity', 'warning', :_blank)
                end
            ].join(' '),
	              link_to(contact.first_name, overseers_contact_creation_request_path(contact), target: '_blank'),
	              contact.last_name,
	              contact.email,
                contact.phone_number.present? ? contact.phone_number : '--',
                contact.mobile_number.present? ? contact.mobile_number : '--',
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
