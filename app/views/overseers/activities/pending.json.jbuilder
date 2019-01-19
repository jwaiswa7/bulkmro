json.data (@activities) do |activity|
  json.array! [

                  [
                      if policy(:activity).perform_actions?;
                        "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='activities[]' class='custom-control-input' value='#{activity.id}' id='c-#{activity.id}'><label class='custom-control-label' for='c-#{activity.id}'></label></div>"
                      end,
                      if policy(activity).edit?;
                        row_action_button(edit_overseers_activity_path(activity), 'pencil', 'Edit Activity', 'warning')
                      end,
                      if (activity.company_creation_request.present? && !activity.company_creation_request.company_id.present? && activity.company_creation_request.present? && policy(activity.company_creation_request).show?);
                        row_action_button(overseers_company_creation_request_path(activity.company_creation_request), 'eye', 'View Company Creation Request', 'info  ')
                      end,
                  ].join(' '),
                  activity.created_by.to_s,
                  if activity.activity_account.present?
                    conditional_link(activity.activity_account.to_s, overseers_account_path(activity.activity_account), policy(activity.activity_account))
                  elsif activity.company_creation_request.present?
                    activity.company_creation_request.account_name
                  else
                    '--'
                  end,
                  if activity.activity_company.present?
                    conditional_link(activity.activity_company.to_s, overseers_company_path(activity.activity_company), policy(activity.activity_company))
                  elsif activity.company_creation_request.present?
                    activity.company_creation_request.name
                  else
                    '--'
                  end,
                  format_enum(activity.company_type),
                  if activity.company_creation_request.present?
                    status_badge(activity.company_creation_request.status)
                  else
                    '--'
                  end,
                  if activity.inquiry.present?
                    link_to format_id(activity.inquiry.inquiry_number), edit_overseers_inquiry_path(activity.inquiry)
                  end,
                  if activity.inquiry.present?
                    status_badge(activity.inquiry.commercial_status)
                  end,
                  if activity.contact.present?
                    activity.contact.to_s
                  end,
                  format_enum(activity.purpose),
                  format_enum(activity.activity_type),
                  activity.points_discussed,
                  activity.actions_required,
                  format_date(activity.created_at)
              ]
end

json.recordsTotal @activities.model.all.count
json.recordsFiltered @activities.total_count
json.draw params[:draw]