json.data (@customer_feedbacks) do |customer_feedback|
    json.array! [
        customer_feedback.customer_email,
        customer_feedback.experience,
        customer_feedback.most_liked,
        customer_feedback.to_improve,
        customer_feedback.comments
                ]
  end
  
  json.recordsTotal @customer_feedbacks.model.all.count
  json.recordsFiltered @customer_feedbacks.total_count
  json.draw params[:draw]