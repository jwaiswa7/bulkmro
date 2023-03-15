json.data (@activities) do |activity|
  json.array! [
                  if is_authorized(:activity, 'perform_actions');
                    "<div class='d-none d-md-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='activities[]' class='custom-control-input' value='#{activity.id}' id='c-#{activity.id}'><label class='custom-control-label' for='c-#{activity.id}'></label></div>"
                  end,
                  [
                      if is_authorized(activity, 'edit') && policy(activity).edit?;
                        row_action_button(edit_overseers_activity_path(activity), 'pencil', 'Edit Activity', 'warning', :_blank)
                      end,
                      if !activity.company.present? && activity.company_creation_request.present? && !activity.company_creation_request.company_id.present? && is_authorized(activity.company_creation_request, 'show');
                        row_action_button(overseers_company_creation_request_path(activity.company_creation_request), 'eye', 'View Company Creation Request', 'info  ')
                      end,
                      if !activity.contact.present? && activity.contact_creation_request.present? && !activity.contact_creation_request.contact_id.present? && is_authorized(activity.contact_creation_request, 'show');
                        row_action_button(overseers_contact_creation_request_path(activity.contact_creation_request), 'eye', 'View Contact Creation Request', 'info  ')
                      end,
                  ].join(' '),
                  activity.subject,
                  status_badge(activity.activity_status),
                  if activity.activity_account.present?
                    conditional_link(activity.activity_account.to_s, overseers_account_path(activity.activity_account), is_authorized(activity, 'activity_account'))
                  end,
                  if activity.activity_company.present?
                    conditional_link(activity.activity_company.to_s, overseers_company_path(activity.activity_company), is_authorized(activity, 'activity_company'))
                  elsif activity.company_creation_request.present?
                    activity.company_creation_request.name
                  else
                    ''
                  end,
                  if activity.company_creation_request.present?
                    status_badge(activity.company_creation_request.status)
                  else
                    ''
                  end,
                  if activity.inquiry.present?
                    link_to format_id(activity.inquiry.inquiry_number), edit_overseers_inquiry_path(activity.inquiry)
                  end,
                  activity.created_by.to_s,
                  activity.overseers.map {|o| o.to_s}.compact.join('</br></br>'),
                  activity.points_discussed,
                  activity.actions_required,
                  format_date(activity.activity_date),
                  format_succinct_date(activity.due_date),
                   if activity.inquiry.present?
                    status_badge(activity.inquiry.commercial_status)
                  end,
                  if activity.contact.present?
                    link_to(activity.contact.to_s, overseers_contact_path(activity.contact), target: '_blank')
                  end,
                  format_enum(activity.purpose),
                  format_enum(activity.activity_type),
                  format_currency(activity.expenses),


              ]
end
json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [{ "source": autocomplete_overseers_accounts_path }],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       [],
                       Overseer.outside.map { |value| { 'label' => value.name.to_s, 'value' => value.id } }.as_json,
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{ "source": autocomplete_overseers_contacts_path }],
                       Activity.purposes.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       Activity.activity_types.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       []
                   ]

json.recordsTotal @activities.model.all.count
json.recordsFiltered @indexed_activities.total_count
json.draw params[:draw]
json.recordsSummary Activity.activity_types.map { |status, status_id| {'status_id': status_id,'label':status, size:  Activity.send(status).size }}.as_json
json.recordsMainSummary Activity.activity_types.map { |status, status_id| {'status_id': status_id,'label':status, size:  Activity.send(status).size }}.as_json
