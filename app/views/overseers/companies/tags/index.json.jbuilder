json.data (@tags) do |tag|
  json.array! [

                  [
                      if policy(tag).show?
                        row_action_button(overseers_company_tag_path(tag.company, tag), 'fal fa-eye', 'View tag', 'dark')
                      end,
                      if policy(tag).edit?
                        row_action_button(edit_overseers_company_tag_path(tag.company, tag), 'pencil', 'Edit tag', 'warning')
                      end,
                      # if policy(tag).destroy?
                      #   row_action_button(overseers_company_tag_path(tag.company, tag),'trash', 'Delete tag', 'danger', '' ,:delete)
                      # end
                  ].join(' '),
                  tag.name.to_s.truncate(50),
                  format_date(tag.created_at)
              ]
end

json.recordsTotal @company.tags.count
json.recordsFiltered @tags.total_count
json.draw params[:draw]