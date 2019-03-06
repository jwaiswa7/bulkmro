class Overseers::DocumentCreationsController < Overseers::BaseController
  def new
    authorize :document_creation
  end

  def create
    authorize :document_creation
    if doc_creation_params["option"] == "Purchase Order"
      @po = PurchaseOrder.find_by_po_number(doc_creation_params["document_number"])
      if @po.present?
        redirect_to new_overseers_document_creation_path(id: @po.id, number: @po.po_number, option: doc_creation_params["option"]), notice: "Purchase Order already exists"
      else
        Resources::PurchaseOrder.set_purchase_order_items([doc_creation_params["document_number"].to_i])
        redirect_to new_overseers_document_creation_path, notice: "Purchase Order created"
      end
    else
      @si = SalesInvoice.find_by_invoice_number(doc_creation_params["document_number"])
      if @si.present?
        redirect_to new_overseers_document_creation_path(id: @si.id, number: @si.invoice_number, option: doc_creation_params["option"]), notice: "Sales Invoice already exists"
      else
        Resources::Invoice.set_invoice_items([doc_creation_params["document_number"].to_i])
        redirect_to new_overseers_document_creation_path, notice: "Sales Invoice created"
      end
    end
  end

  private

  def doc_creation_params
    params.require(:document_creation).permit(
      :option,
      :document_number
    )
  end
end
