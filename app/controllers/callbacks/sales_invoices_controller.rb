class Callbacks::SalesInvoicesController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback
  def create
    #request params {"store_id":null,"base_grand_total":"17858.12","doc_entry":"2951","shipping_tax_amount":null,"tax_amount":"2724.12","base_tax_amount":"2724.12","store_to_order_rate":"1","base_shipping_tax_amount":null,"base_discount_amount":null,"base_to_order_rate":"1","grand_total":"17858.12","shipping_amount":null,"subtotal_incl_tax":"17858.12","base_subtotal_incl_tax":"17858.12","base_shipping_amount":null,"total_qty":"115","base_to_global_rate":"1","subtotal":"15134","base_subtotal":"15134","discount_amount":"","billing_address_id":"5208","is_used_for_refund":null,"shipment_no":"30610579","order_id":"10610109","email_sent":null,"can_void_flag":null,"state":"206","shipping_address_id":"5208","store_currency_code":"INR","transaction_id":null,"order_currency_code":"INR","base_currency_code":"INR","global_currency_code":"INR","increment_id":"20610438","created_at":"2018-09-10","updated_at":null,"hidden_tax_amount":null,"base_hidden_tax_amount":null,"shipping_hidden_tax_amount":null,"base_shipping_hidden_tax_amnt":null,"shipping_incl_tax":null,"base_shipping_incl_tax":null,"base_total_refunded":null,"discount_description":null,"is_kit":"","desc_kit":"","qty_kit":"0","price_kit":"0","unitprice_kit":"0","customer_company":null,"attachment_entry":"","ItemLine":[{"base_price":"131.6","tax_amount":"2724.12","base_row_total":"15134","discount_amount":"0","row_total":"15134","base_discount_amount":"0","price_incl_tax":null,"base_tax_amount":"2724.12","base_price_incl_tax":null,"qty":"115","base_cost":null,"price":"131.6","base_row_total_incl_tax":"17858.12","row_total_incl_tax":"17858.12","product_id":"759275","order_item_id":"","additional_data":null,"description":"SEAL Markel make DIMENSION : 36X46X7.30 MM","sku":"BM9P4N8","name":"SEAL Markel make DIMENSION : 36X46X7.30 MM","hidden_tax_amount":null,"base_hidden_tax_amount":null,"base_weee_tax_applied_amount":null,"base_weee_tax_applied_row_amnt":null,"weee_tax_applied_amount":null,"weee_tax_applied_row_amount":null,"weee_tax_applied":null,"weee_tax_disposition":null,"weee_tax_row_disposition":null,"base_weee_tax_disposition":null,"base_weee_tax_row_disposition":null}]}
    # @sales_order = SalesOrder.find_by_remote_id(params[:increment_id])
    puts 'create new'

    render json: params, status: :ok
  end
  def update
    #same as
    # @sales_order = SalesOrder.find_by_remote_id(params[:increment_id])
    puts 'Lets update'

    render json: params, status: :ok
  end
end