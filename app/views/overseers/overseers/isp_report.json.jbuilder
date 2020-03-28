json.data (@records) do |record|
  json.array! [
              record[:name],
              record[:inquiries_count],
              record[:sales_quotes_count],
              record[:sales_orders_count],
              record[:purchase_orders_count]
              ]
end
json.recordsTotal @records.count
json.recordsFiltered @records.total_count
json.draw params[:draw]
