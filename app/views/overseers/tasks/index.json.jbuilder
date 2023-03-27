json.data (@tasks) do |task|
  json.array! [
                  [
                      if is_authorized(task, 'edit') && policy(task).edit?;
                        row_action_button(edit_overseers_task_path(task), 'pencil', 'Edit Task', 'warning', :_blank)
                      end,
                      if is_authorized(task, 'show') && policy(task).show?;
                        row_action_button(overseers_task_path(task), 'eye', 'View Task', 'warning', :_blank)
                      end,
                      if is_authorized(task, 'comments') && policy(task).comments?
                        row_action_button(overseers_task_comments_path(task), 'comment-lines', 'View Comments', 'dark', :_blank)
                      end,
                  ].join(' '),
                  task.task_id,
                  task.subject,
                  status_badge(task.status),
                  status_badge(task.priority),
                  task.description,
                  task.company.to_s,
                  task.department,
                  task.overseers.map {|o| o.to_s}.compact.join('</br></br>'),
                  task.created_by.to_s,
                  format_succinct_date(task.due_date),
                  format_succinct_date(task.created_at),
                  if task.last_comment.present?
                  format_comment(task.last_comment, trimmed: true)
                  else
                    ""
                  end


              ]
end
json.columnFilters [
                       [],
                       [],
                       [],
                       Task.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       Task.priorities.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [{ "source": autocomplete_overseers_suppliers_path }],
                       Task.departments.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       Overseer.all.alphabetical.map { |s| {"label": s.full_name, "value": s.id.to_s} }.as_json,
                       Overseer.all.alphabetical.map { |s| {"label": s.full_name, "value": s.id.to_s} }.as_json,
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal Task.count
json.recordsFiltered @indexed_tasks.total_count
json.draw params[:draw]
