json.data (@activities) do |activity|
  json.array! [
                  [
                      if policy(activity).edit?; row_action_button(edit_overseers_activity_path(activity), 'pencil', 'Edit Activity', 'warning') end,
                  ].join(' '),
                  activity.created_by.to_s,
                  if activity.activity_account.present?; activity.activity_account.to_s end,
                  if activity.activity_company.present?; activity.activity_company.to_s end,
                  format_enum(activity.company_type),
                  if activity.inquiry.present?; link_to format_id(activity.inquiry.inquiry_number), edit_overseers_inquiry_path(activity.inquiry) end,
                  if activity.inquiry.present?; status_helper_format_label(activity.inquiry.commercial_status) end,
                  if activity.contact.present?; activity.contact.to_s end,
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