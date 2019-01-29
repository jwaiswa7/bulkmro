json.data (@company_reviews) do |company_review|
  json.array! [
                  [
                      if policy(company_review).show?;
                        row_action_button(overseers_company_review_path(company_review), 'eye', 'View Company', 'info', :_blank)
                      end,
                  ],
                  company_review.created_by.name,
                  company_review.rateable.name,
                  rating_for(company_review, "CompanyRating")
              ]
end

json.recordsTotal @company_reviews.model.all.count
json.recordsFiltered @company_reviews.total_count
json.draw params[:draw]
json.companyRating @company_reviews.map {|cmp| {:id=> cmp.id, :"rating"=> cmp.rating}}.as_json