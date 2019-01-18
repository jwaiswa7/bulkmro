json.data (@company_reviews) do |company_review|
  json.array! [
                  [
                      if policy(company_review).show?;
                        row_action_button(overseers_company_review_path(company_review), 'eye', 'View Company', 'info', :_blank)
                      end,
                  ],
                  company_review.overseer.name,
                  company_review.company.name,
                  company_review.rating,
              ]
end

json.recordsTotal @company_reviews.model.all.count
json.recordsFiltered @company_reviews.total_count
json.draw params[:draw]