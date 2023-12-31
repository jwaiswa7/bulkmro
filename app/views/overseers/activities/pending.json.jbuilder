json.data (@activities) do |activity|
  json.array! [
                  if is_authorized(:activity, 'perform_actions');
                    "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='activities[]' class='custom-control-input' value='#{activity.id}' id='c-#{activity.id}'><label class='custom-control-label' for='c-#{activity.id}'></label></div>"
                  end,
                  [
                      if is_authorized(activity, 'edit') && policy(activity).edit?;
                        row_action_button(edit_overseers_activity_path(activity), 'pencil', 'Edit Activity', 'warning', :_blank)
                      end,
                      if activity.company_creation_request.present? && !activity.company_creation_request.company_id.present? && activity.company_creation_request.present? && is_authorized(activity.company_creation_request, 'show');
                        row_action_button(overseers_company_creation_request_path(activity.company_creation_request), 'eye', 'View Company Creation Request', 'info', :_blank)
                      end,
                      if activity.contact_creation_request.present? && !activity.contact_creation_request.contact_id.present? && activity.contact_creation_request.present? && is_authorized(activity.contact_creation_request, 'show');
                        row_action_button(overseers_contact_creation_request_path(activity.contact_creation_request), 'eye', 'View Contact Creation Request', 'info', :_blank)
                      end,
                  ].join(' '),
                  activity.created_by.to_s,
                  format_date(activity.activity_date),
                  if activity.activity_account.present?
                    conditional_link(activity.activity_account.to_s, overseers_account_path(activity.activity_account), is_authorized(activity, 'activity_account'))
                  end,
                  if activity.activity_company.present?
                    conditional_link(activity.activity_company.to_s, overseers_company_path(activity.activity_company), is_authorized(activity, 'activity_company'))
                  elsif activity.company_creation_request.present?
                    activity.company_creation_request.name
                  else
                    '--'
                  end,
                  activity.company_creation_request.present? ? format_boolean(activity.company_creation_request.is_supplier?) : format_boolean(activity.is_supplier?),
                  activity.company_creation_request.present? ? format_boolean(activity.company_creation_request.is_customer?) : format_boolean(activity.is_customer?),
                  if activity.company_creation_request.present?
                    status_badge(activity.company_creation_request.status)
                  else
                    '--'
                  end,
                  if activity.contact_creation_request.present?
                    status_badge(activity.contact_creation_request.status)
                  else
                    '--'
                  end,
                  if activity.inquiry.present?
                    link_to format_id(activity.inquiry.inquiry_number), edit_overseers_inquiry_path(activity.inquiry)
                  end,
                  if activity.contact.present?
                    activity.contact.to_s
                  end,
                  format_enum(activity.purpose),
                  format_enum(activity.activity_type),
                  format_currency(activity.expenses),
                  activity.points_discussed,
                  activity.actions_required,
                  format_date(activity.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       Overseer.outside.map { |value| { 'label' => value.name.to_s, 'value' => value.id } }.as_json,
                       [],
                       [{ "source": autocomplete_overseers_accounts_path }],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{ "source": autocomplete_overseers_contacts_path }],
                       Activity.purposes.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       Activity.activity_types.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [],
                       [],
                       [],

                   ]

json.recordsTotal @activities.model.all.count
json.recordsFiltered @indexed_activities.total_count
json.draw params[:draw]