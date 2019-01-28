json.data (@activities) do |activity|
  json.array! [
                  [
                      if policy(:activity).perform_actions?;
                        "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='activities[]' class='custom-control-input' value='#{activity.id}' id='c-#{activity.id}'><label class='custom-control-label' for='c-#{activity.id}'></label></div>"
                      end,
                      if policy(activity).edit?;
                        row_action_button(edit_overseers_activity_path(activity), 'pencil', 'Edit Activity', 'warning')
                      end,
                  ].join(' '),
                  activity.created_by.to_s,
                  format_date(activity.activity_date),
                  if activity.activity_account.present?
                    conditional_link(activity.activity_account.to_s, overseers_account_path(activity.activity_account), policy(activity.activity_account))
                  end,
                  if activity.activity_company.present?
                    conditional_link(activity.activity_company.to_s, overseers_company_path(activity.activity_company), policy(activity.activity_company))
                  end,
                  if activity.inquiry.present?
                    link_to format_id(activity.inquiry.inquiry_number), edit_overseers_inquiry_path(activity.inquiry)
                  end,
                  if activity.contact.present?
                    activity.contact.to_s
                  end,
                  format_enum(activity.purpose),
                  format_enum(activity.activity_type),
                  activity.daily_allowance,
                  activity.points_discussed,
                  activity.actions_required,
                  format_succinct_date(activity.created_at)
              ]
end

json.recordsTotal @activities.model.all.count
json.recordsFiltered @activities.total_count
json.draw params[:draw]