json.data (@review_questions) do |review_question|
  json.array! [
                  [
                      if is_authorized(review_question, 'show')
                        row_action_button_without_fa(overseers_review_question_path(review_question), 'bmro-icon-table bmro-icon-used-view', 'Edit Review Question', 'info')

                      end,
                      if is_authorized(review_question, 'edit')
                        row_action_button_without_fa(edit_overseers_review_question_path(review_question), 'bmro-icon-table bmro-icon-pencil', 'Edit Review Question', 'warning')
                      end,
                      if is_authorized(review_question, 'destroy')
                        row_action_button_without_fa(overseers_review_question_path(review_question), 'bmro-icon-table bmro-icon-used-trash', 'Delete Review Question', 'danger', '', :delete)
                      end
                  ].join(' '),
                  review_question.question,
                  format_enum(review_question.question_type),
                  review_question.weightage

              ]
end
json.recordsTotal @review_questions.model.all.count
json.recordsFiltered @review_questions.total_count
json.draw params[:draw]
