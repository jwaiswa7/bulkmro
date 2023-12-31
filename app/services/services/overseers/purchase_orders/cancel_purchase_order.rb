class Services::Overseers::PurchaseOrders::CancelPurchaseOrder < Services::Shared::BaseService
  def initialize(purchase_order, params)
    @purchase_order = purchase_order
    @purchase_order_params = params
  end

  def call
    if purchase_order_params['comments_attributes']['0']['message'].present?
      if purchase_order.remote_uid.present?
        remote_status = ::Resources::PurchaseOrder.cancel_document(purchase_order)
        if remote_status.key?('status') && remote_status['status'] == 'success'
          @status = purchase_order_cancel(purchase_order, purchase_order_params)
        elsif remote_status.key?('status') && remote_status['status'] == 'failed'
          @status = { status: 'failed', message: remote_status['message'] }
        end
      elsif purchase_order.remote_uid.blank?
        @status = purchase_order_cancel(purchase_order, purchase_order_params)
      end
    else
      @status = { empty_message: 'true', message: 'Comment message is required' }
    end
    @status
  end


  def purchase_order_cancel(purchase_order, purchase_order_params)
    purchase_order.comments.build(message: "#{purchase_order_params['comments_attributes']['0']['message']}", created_by_id: purchase_order_params['created_by_id'])
    purchase_order.status = purchase_order_params['status']
    if purchase_order.po_request.present?
      purchase_order.po_request.status = 'Cancelled'
      purchase_order.po_request.save!
    end
    purchase_order.save
    # tcs_for_po
    # company = purchase_order.company
    # if company
    #   company_po_amount = company.company_transactions_amounts.where(financial_year: Company.current_financial_year).last
    #   company_po_amount.decrement_total_amount(purchase_order.calculated_total_with_tax_with_or_without_tcs) if company_po_amount.present?
    # end
    { status: 'success', message: 'Purchase Order Cancelled Successfully' }
  end


  attr_accessor :purchase_order, :purchase_order_params
end
