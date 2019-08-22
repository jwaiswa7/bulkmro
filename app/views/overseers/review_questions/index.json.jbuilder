json.data (@review_questions) do |review_question|
  json.array! [
                  [
                      if is_authorized(review_question, 'show')
                        row_action_button(overseers_review_question_path(review_question), 'eye', 'Edit Review Question', 'info')

                      end,
                      if is_authorized(review_question, 'edit')
                        row_action_button(edit_overseers_review_question_path(review_question), 'pencil', 'Edit Review Question', 'warning')
                      end,
                      if is_authorized(review_question, 'destroy')
                        row_action_button(overseers_review_question_path(review_question), 'trash', 'Delete Review Question', 'danger', '', :delete)
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
