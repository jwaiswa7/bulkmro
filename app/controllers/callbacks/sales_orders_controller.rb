class Callbacks::SalesOrdersController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback

  def create
    response_status = 0
    response_message = 'Invalid request.'
    response_payload = ''

    request = log_request(:callback, "Order", params)

    #request params: {"U_MgntDocID":"942","Status":"1","comment":"","DocNum":"10300008","DocEntry":"609","UserEmail":"35","SapReject":""}
    #
    #In create U_MgntDocID is ref id vaule sent while creating sales draft from magento to SAP

    if params['U_MgntDocID'] && params['Status'] && params['DocEntry']

      sales_order = SalesOrder.find_by_doc_number(params['DocEntry']) || SalesOrder.find_by_legacy_id(params['U_MgntDocID'])

      if sales_order.present?
        if params['Status'] == '1'
          #create order from quotation and take actions like add products / billing-shpping address / tax etc, update so draft
          #in response send all order product details like below. ref: #'U_MgntDocID' => orderID,'ItemCode' => Sku,'OrderItemId' => itemId

          if sales_order.approved? && !sales_order.rejected?
            if sales_order.order_status != 'approved'

              sales_order.order_number = params['DocNum']
              sales_order.set_status('approved')

              response_message = "Order Created Successfully"
              items = []
              comment_message = params['comment_message']
              comment_message = ["SAP Status Updated: ", sales_order.remote_status, " Comment: ", comment_message].join
              create_sap_comment(comment_message, sales_order.inquiry)
              sales_order.rows.each do |row|
                item = OpenStruct.new({U_MgntDocID: sales_order.order_number, ItemCode: row.sales_quote_row.product.sku, OrderItemId: row.to_remote_s})
                items.push(item.marshal_dump)
              end

              response_payload = {
                  U_MgntDocID: sales_order.order_number,
                  DocumentLines: items
              }
            end

          end

        elsif params['Status'] == '2'
          #sap reject also add comment
          # UPDATE order_request_flow SET  request_status = 'SAP Rejected' , sap_reject = 1  WHERE order_request_id
          response_message = "SO Draft Rejected Successfully"
          response_status = 1

          if sales_order.approved? && !sales_order.rejected?
            comment = create_sap_comment(params['comment'], sales_order.inquiry)
            sales_order.approval.destroy
            sales_order.create_rejection(:comment => comment, :overseer => Overseer.sap_approver)
            sales_order.set_status('SAP Rejected')
          else
            response_message = "SO Already Rejected. Cannot change status"
          end
        elsif params['Status'] == '3'
          #UPDATE order_request_flow SET request_stHold by financeatus = 'Hold by finance', sap_reject = 2 WHERE order_request_id
          #sap reject also add comment
          response_status = 1
          response_message = "SO Draft Updated Successfully. Status: Hold by Finance"


          if sales_order.approved? && !sales_order.rejected?
            comment = create_sap_comment(params['comment'], sales_order.inquiry)
            comment.message = ["Status: Hold by Finance | ", comment.message].join
            sales_order.approval.destroy
            sales_order.create_rejection(:comment => comment, :overseer => Overseer.sap_approver)
            sales_order.set_status('Hold by Finance')
          else
            response_message = "SO Already Rejected. Cannot change status"
          end
        else
          response_message = "Invalid/Unknown Status received from SAP.";
        end
        sales_order.save
      end


    end

    response = format_response(response_status, response_message, response_payload)
    request.response_message = response.to_json
    request.status = :success
    request.save

    render json: response, status: :ok
  end

  def create_sap_comment(message, inquiry)
    comment = InquiryComment.create(message: message, inquiry: inquiry, overseer: Overseer.sap_approver)
  end

  def update
    response_status = 0
    response_message = 'Invalid request.'
    response_payload = ''

    request = log_request(:callback, "Update Order", params)
    #request params: {"increment_id":"2001656","sap_order_status":"30","comment":"","DocNum":"2001656","DocEntry":"2169","UserEmail":"35","SapReject":""}
    # In update increment_id and DocNum are same
    if params['increment_id'] && params['sap_order_status']
      #update order based on status (like cancel) and add comment
      sales_order = SalesOrder.find_by_order_number(params['increment_id'])
      response_status = 1
      comment = ""
      response_message = "Sales Order not Found"
      if sales_order.present?
        response_message = "Order Updated Successfully"

        if !params['comment'].blank?
          comment = params['comment']
        end

        if !params['sap_order_status'].blank? || !comment.blank?
          #cancel the order along with update quote product qty and cancel order item qty
          new_status = params['sap_order_status'].to_i
          if SalesOrder.remote_statuses.has_value?(new_status)
            old_status = sales_order.remote_status
            sales_order.remote_status = params['sap_order_status'].to_i
            #sales_order.remote_status = "SAP Approved"
            sales_order.save

            if sales_order.remote_status != old_status
              if comment.blank?
                comment = ["SAP Status Updated: ", sales_order.remote_status].join
              else
                comment = ["SAP Status Updated: ", sales_order.remote_status, comment].join
              end
            end
          else
            comment = ["Incorrect Status Code: ", new_status].join
            response_status = 0
            response_message = "Nothing to Update. Incorrect Order Status Recieved"
          end

          InquiryComment.create(message: comment, inquiry: sales_order.inquiry, overseer: Overseer.sap_approver)

        else
          response_message = "Nothing to Update"
        end

      end
    end

    response = format_response(response_status, response_message)
    request.response_message = response.to_json
    request.status = :success
    request.save

    render json: response, status: :ok
  end
end