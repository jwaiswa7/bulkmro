class Overseers::DocumentCreationsController < Overseers::BaseController
  def new
    authorize :document_creation
  end

  def create
    authorize :document_creation
    if doc_creation_params["option"] == "Purchase Order"
      if PurchaseOrder.where(po_number: doc_creation_params["number"]).first.present?
        redirect_to new_overseers_document_creation_path, :notice => "Purchase Order already exists"
      else
        redirect_to new_overseers_document_creation_path, :notice => "Purchase Order creation request initiated"
        Resources::PurchaseOrder.set_purchase_order_items([doc_creation_params["number"].to_i])
      end
    else
      if SalesInvoice.where(invoice_number: doc_creation_params["number"]).first.present?
        redirect_to new_overseers_document_creation_path, :notice => "Sales Invoice already exists"
      else
        redirect_to new_overseers_document_creation_path, :notice => "Sales Invoice creation request initiated"
        Resources::Invoice.set_invoice_items([doc_creation_params["number"].to_i])
      end
    end
  end

  private

  def doc_creation_params
    params.require(:document_creation).permit(
      :inquiry,
      :sales_order,
      :option,
      :number
    )
  end
end
