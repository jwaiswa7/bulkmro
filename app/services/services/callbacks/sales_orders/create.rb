class Services::Callbacks::SalesOrders::Create < Services::Callbacks::Shared::BaseCallback

  def call
    sprint_order_id = params['U_MgntDocID']
    remote_status = params['Status']
    remote_comment = params['comment']
    remote_uid = params['DocEntry']
    order_number = params['DocNum']
    comment_message = [
        ['SAP Status Updated', remote_status].join(': '),
        ['Comment', remote_comment].join(': '),
    ].join(' | ')

    sales_order = SalesOrder.find(sprint_order_id)

    if sales_order.present?
      case to_local_status(remote_status)
      when :'approved'
        if sales_order.approved?
          return_response("Order Already Approved")
        elsif sales_order.remote_status.blank?
          begin
            sales_order.update_attributes(:remote_status => :'Supplier PO: Request Pending', :status => :'approved', :order_number => order_number, :remote_uid => remote_uid)
            sales_order.inquiry.comments.create!(message: "SAP Approved", overseer: Overseer.default_approver)
            return_response("Order Created Successfully")
          rescue => e
            return_response(e.message, 0)
          end
        end
      when :'SAP Rejected'
        begin
          sales_order.update_attributes(:status => :'SAP Rejected')
          comment = sales_order.inquiry.comments.create!(message: comment_message, overseer: Overseer.default_approver)
          sales_order.create_rejection!(:comment => comment, :overseer => Overseer.default_approver)
          sales_order.approval.destroy!
          return_response("Order Rejected Successfully")
        rescue => e
          return_response(e.message, 0)
        end
      end
    else
      return_response("Order Not Processed", 0)
    end
  end

  def to_local_status(remote_status)
    case remote_status
    when '1'
      :'approved'
    when '2'
      :'SAP Rejected'
    when '3'
      :'SAP Rejected'
    end
  end
end

# {
#     "U_MgntDocID":"942",
#     "Status":"1",
#     "comment":"",
#     "DocNum":"10300008",
#     "DocEntry":"609",
#     "UserEmail":"35",
#     "SapReject":""
# }