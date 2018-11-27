class Services::Callbacks::SalesShipments::Create < Services::Callbacks::Shared::BaseCallback

  def call
    begin
      sales_order = SalesOrder.find_by_order_number(params['order_id'])

      if sales_order.present?
        sales_shipment = sales_order.shipments.where(shipment_number: params['increment_id']).first_or_create! do |sales_shipment|
          sales_shipment.created_at = params['created_at'].to_datetime
          sales_shipment.overseer = Overseer.default_approver
          sales_shipment.metadata = params
        end

        params['ItemLine'].each do |remote_row|
          sales_shipment.rows.where(sku: remote_row['sku']).first_or_create! do |row|
            row.assign_attributes(
                :quantity => remote_row['qty'],
                :metadata => remote_row
            )
          end
        end

        params['TrackLine'].each do |remote_package|
          if remote_package['track_number'].present?
            sales_shipment.packages.where(tracking_number: remote_package['track_number']).first_or_create! do |package|
              package.assign_attributes(
                  :metadata => remote_package,
                  :sales_order => sales_order
              )
            end
          else
            return_response("Tracking Number is mandatory.", 0)
          end
        end
        return_response("Sales Shipment created successfully.")
      else
        return_response("Sales Order not found.", 0)
      end
    rescue => e
      return_response(e.message, 0)
    end
  end

  attr_accessor :params
end