class Callbacks::ActivitiesController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback

  def create
    resp_status = 0
    resp_msg = 'Document Id not found'
    #request params: {"magento_id":"10210028","comments":"","comment_type":"o","email":"","created_at":"2018-05-09"}

    if params['magento_id'] #In magneto its increment_id of respective modules
      # from params['email'] get user id and role say user_id and user_role
      #from params['magento_id'] get quotation_id
      begin
        if user_role == 'outside'
          #Update quotation os_comment = params['comments'], ose_comment_by = user_id where increment_id = quotation_id
        else
          #Update quotation is_comment = params['comments'], ise_comment_by = user_id where increment_id = quotation_id
        end

        case params['comment_type']
          when 'q'
            #insert into inquiry_comments_log inquiry_comments_log_id(pk), comments_inquiryid = quotation_id, comments = params['comments'], comments_username = user_id, created_at = params ['created_at'], inquiry_increment_id = quotation_id, invoice_increment_id = '', order_increment_id = '', shipment_increment_id = '', po_increment_id = '', comment_type = 'Quotation'
          when 'o'
            #insert into inquiry_comments_log inquiry_comments_log_id(pk), comments_inquiryid = quotation_id, comments = params['comments'], comments_username = user_id, created_at = params ['created_at'], inquiry_increment_id = quotation_id, invoice_increment_id = '', order_increment_id = order_id, shipment_increment_id = '', po_increment_id = '', comment_type = 'Order'
          when 'i'
            #insert into inquiry_comments_log inquiry_comments_log_id(pk), comments_inquiryid = quotation_id, comments = params['comments'], comments_username = user_id, created_at = params ['created_at'], inquiry_increment_id = quotation_id, invoice_increment_id = invoice_id, order_increment_id = '', shipment_increment_id = '', po_increment_id = '', comment_type = 'Invoice'
          when 's'
            #insert into inquiry_comments_log inquiry_comments_log_id(pk), comments_inquiryid = quotation_id, comments = params['comments'], comments_username = user_id, created_at = params ['created_at'], inquiry_increment_id = quotation_id, invoice_increment_id = '', order_increment_id = '', shipment_increment_id = shipment_id, po_increment_id = '', comment_type = 'Invoice'"You passed a string"
          when 'p'
            #insert into inquiry_comments_log inquiry_comments_log_id(pk), comments_inquiryid = quotation_id, comments = params['comments'], comments_username = user_id, created_at = params ['created_at'], inquiry_increment_id = quotation_id, invoice_increment_id = '', order_increment_id = '', shipment_increment_id = '', po_increment_id = po_id, comment_type = 'Invoice'"You passed a string"
        end
        resp_status = 1
        resp_msg = "Activity Created Successfully"
      rescue => ex
        resp_status = 0
        resp_msg = ex.message
      end
    end
    response = format_response(resp_status, resp_msg)
    render json: response, status: :ok
  end
end