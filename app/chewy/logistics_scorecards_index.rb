class LogisticsScorecardsIndex < BaseIndex
  opportunity_type = Inquiry.opportunity_types
  delay_reason = SalesInvoice.delay_reasons

  index_scope SalesInvoice.eager_load(:rows).joins(:company).with_inquiry.not_cancelled.with_includes.ignore_freight_bm.where.not(companies: {logistics_owner_id: [96, 107, 213]})
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i if record.inquiry.present? }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :inquiry_date, value: -> (record) { record.inquiry.created_at if record.inquiry.present? }, type: 'date'
    field :company_id, value: -> (record) { record.inquiry.company.id if record.inquiry.present? }, type: 'integer'
    field :company, value: -> (record) { record.inquiry.company.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner_id if record.inquiry.present? }, type: 'integer'
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.name if record.inquiry.present? }, analyzer: 'substring'
    field :logistics_owner_id, value: -> (record) { record.inquiry.company.logistics_owner_id if record.inquiry.present? && record.inquiry.company.present? }, type: 'integer'
    field :logistics_owner, value: -> (record) { record.inquiry.company.logistics_owner&.name if record.inquiry.present? && record.inquiry.company.present? }, analyzer: 'substring'
    field :opportunity_type, value: -> (record) { opportunity_type[record.inquiry.opportunity_type] if record.inquiry.present? }, type: 'integer'

    field :rows do
      field :sku, value: -> (record) { record.try(:sku) }, analyzer: 'sku_substring'
      field :name, value: -> (record) { record.try(:name) }, analyzer: 'substring'
      field :brand, value: -> (record) { record.try(:brand) }, analyzer: 'substring'
      field :quantity, value: -> (record) { record.try(:quantity) }, type: 'double'
    end

    field :so_delivery_location, value: -> (record) { record.inquiry.shipping_address.legacy_metadata["state_name"] if record.inquiry.present? && record.inquiry.shipping_address.legacy_metadata.present? }, analyzer: 'substring'
    field :customer_po_date, value: -> (record) { record.inquiry.customer_order_date if record.inquiry.customer_order_date.present? }, type: 'date'
    field :customer_po_received_date, value: -> (record) { record.inquiry.customer_po_received_date.present? ? record.inquiry.customer_po_received_date : record.inquiry.customer_order_date }, type: 'date'
    field :cp_committed_date, value: -> (record) { record.inquiry.customer_committed_date if record.inquiry.customer_committed_date.present? }, type: 'date'
    field :so_created_at, value: -> (record) { record.sales_order.created_at }, type: 'date'
    field :actual_delivery_date, value: -> (record) { record.try(:delivery_date) }, type: 'date'
    field :committed_delivery_tat, value: -> (record) { record.try(:calculated_committed_delivery_tat) }, type: 'date'
    field :actual_delivery_tat, value: -> (record) { record.try(:calculated_actual_delivery_tat) }, type: 'date'
    field :delay, value: -> (record) { record.try(:calculated_delay) }, type: 'date'
    field :sla_bucket, value: -> (record) { record.try(:calculated_sla_bucket) }, analyzer: 'substring', fielddata: true
    field :delay_bucket, value: -> (record) { record.try(:calculated_delay_bucket) }, type: 'integer'
    field :delay_reason, value: -> (record) { record.delay_reason.present? ? delay_reason[record.delay_reason] : 40 }, type: 'integer'
    field :created_at, value: -> (record) { record.created_at }, type: 'date'

    field :sales_order, type: 'nested' do
      field :po_requests, type: 'nested' do
        field :purchase_order do
          field :supplier_po_created_date, value: -> (record) { record.created_at }, type: 'date'
        end
      end
    end

end

# ====================================== Do not Remove ==============================================================================================================================================
# class LogisticsScorecardsIndex < BaseIndex
#   opportunity_type = Inquiry.opportunity_types
#   delay_reason = SalesInvoice.delay_reasons
#
#   index_scope SalesInvoice.eager_load(:rows).with_inquiry.not_cancelled.with_includes.ignore_freight_bm do
#     field :id, type: 'integer'
#     field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i if record.inquiry.present? }, type: 'integer'
#     field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: 'substring'
#     field :inquiry_date, value: -> (record) { record.inquiry.created_at if record.inquiry.present? }, type: 'date'
#     field :company_id, value: -> (record) { record.inquiry.company.id if record.inquiry.present? }, type: 'integer'
#     field :company, value: -> (record) { record.inquiry.company.to_s if record.inquiry.present? }, analyzer: 'substring'
#     field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner_id if record.inquiry.present? }, type: 'integer'
#     field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.name if record.inquiry.present? }, analyzer: 'substring'
#     field :logistics_owner_id, value: -> (record) { record.inquiry.company.logistics_owner_id if record.inquiry.present? }, type: 'integer'
#     field :logistics_owner, value: -> (record) { record.inquiry.company.logistics_owner&.name if record.inquiry.present? && record.inquiry.company.present? }, analyzer: 'substring'
#     field :opportunity_type, value: -> (record) { opportunity_type[record.inquiry.opportunity_type] if record.inquiry.present? }, type: 'integer'
#
#     field :rows do
#       field :sku, value: -> (record) { record.try(:sku) }, analyzer: 'sku_substring'
#       field :name, value: -> (record) { record.try(:name) }, analyzer: 'substring'
#       field :brand, value: -> (record) { record.try(:brand) }, analyzer: 'substring'
#       field :quantity, value: -> (record) { record.try(:quantity) }, type: 'double'
#     end
#
#     field :so_delivery_location, value: -> (record) { record.inquiry.shipping_address.legacy_metadata["state_name"] if record.inquiry.present? && record.inquiry.shipping_address.legacy_metadata.present? }, analyzer: 'substring'
#     field :customer_po_date, value: -> (record) { record.inquiry.customer_order_date if record.inquiry.customer_order_date.present? }, type: 'date'
#     field :customer_po_received_date, value: -> (record) { record.inquiry.customer_po_received_date.present? ? record.inquiry.customer_po_received_date : record.inquiry.customer_order_date }, type: 'date'
#     field :cp_committed_date, value: -> (record) { [143, 725, 1444, 1392].include?(record.inquiry.company.id) ? record.created_at : (record.inquiry.customer_committed_date if record.inquiry.customer_committed_date.present?) }, type: 'date'
#     field :so_created_at, value: -> (record) { record.sales_order.created_at }, type: 'date'
#     field :actual_delivery_date, value: -> (record) { [143, 725, 1444, 1392].include?(record.inquiry.company.id) ? record.created_at : record.try(:delivery_date) }, type: 'date'
#     field :committed_delivery_tat, value: -> (record) { record.try(:calculated_committed_delivery_tat) }, type: 'date'
#     field :actual_delivery_tat, value: -> (record) { record.try(:calculated_actual_delivery_tat) }, type: 'date'
#     field :delay, value: -> (record) { record.try(:calculated_delay) }, type: 'date'
#     field :sla_bucket, value: -> (record) { record.try(:calculated_sla_bucket) }, analyzer: 'substring', fielddata: true
#     field :delay_bucket, value: -> (record) { record.try(:calculated_delay_bucket) }, type: 'integer'
#     field :delay_reason, value: -> (record) { record.delay_reason.present? ? delay_reason[record.delay_reason] : 50 }, type: 'integer'
#     field :created_at, value: -> (record) { record.created_at }, type: 'date'
#
#     field :sales_order, type: 'nested' do
#       field :po_requests, type: 'nested' do
#         field :purchase_order do
#           field :supplier_po_created_date, value: -> (record) { record.created_at }, type: 'date'
#         end
#       end
#     end
#   end
# end
# ===================================================================================================================================================================================================
