class Services::Overseers::PurchaseOrders::RejectPurchaseOrder < Services::Shared::BaseService
  def initialize(params, po_request)
    @params = params
    @po_request_obj = po_request
  end

  def call
    if PoRequest.rejection_reasons.key(params[:status].to_i) == 'Others'
      if params[:po_request][:comments_attributes]['0'][:message].blank?
        po_request_obj.errors.add(:base, 'Please Enter Message')
        false
      else
        add_new_comment(true)
        true
      end
    else
      add_new_comment(false)
      true
    end
  end

  def add_new_comment(is_message_present)
    comments = PoRequestComment.new
    json = params[:po_request][:comments_attributes]['0'].as_json
    if !is_message_present
      json['message'] = PoRequest.rejection_reasons.key(params[:status].to_i)
      comments.assign_attributes(json)
    end
    comments.assign_attributes(json)
    comments.save!
    po_request_obj.update_attribute(:status, 'Supplier PO Request Rejected')
  end

  attr_accessor :params, :po_request_obj
end
