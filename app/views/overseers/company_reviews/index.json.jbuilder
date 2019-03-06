json.data (@company_reviews) do |company_review|
  json.array! [
                  [
                      if policy(company_review).show?
                        row_action_button(overseers_company_review_path(company_review), 'eye', 'View Company', 'info', :_blank)
                      end,
                      format_review_document(company_review)
                  ].join(' '),
                  company_review.created_by.name,
                  company_review.company.name,
                  company_review.survey_type,
                  format_star(company_review.rating)
              ]
end

json.recordsTotal @company_reviews.model.where.not(rating: nil).count
json.recordsFiltered @company_reviews.total_count
json.draw params[:draw]
