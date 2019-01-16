json.data (@payments) do |payment|
  json.array! [
                  '',
                  payment.payment_id,
                  payment.status,
                  payment.amount,
                  format_succinct_date(payment.created_at)
              ]
end

json.recordsTotal @payments.model.all.count
json.recordsFiltered @payments.count
json.draw params[:draw]