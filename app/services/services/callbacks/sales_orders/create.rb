class Services::Callbacks::SalesOrders::Create < Services::Shared::BaseService

  def initialize(params)
    @params = params
  end

  def call
    #legacy_id = params['U_MgntDocID']
    sprint_order_id = params['U_MgntDocID']
    remote_status = params['Status']
    remote_comment = params['comment']
    remote_uid = params['DocEntry']
    order_number = params['DocNum']
    comment_message = comment_message_for(remote_status, remote_comment)
    sales_order = SalesOrder.find(sprint_order_id) # || SalesOrder.find_by_legacy_id(legacy_id)

    if sales_order.present?

      case to_local_status(remote_status)
      when :'approved'
        if sales_order.approved?
          {success: 1, status: 1, message: "Order Already Approved"}
        end

        if sales_order.remote_status.blank?
          begin
            sales_order.update_attributes(:remote_status => :'Supplier PO: Request Pending' , :status => :'approved', :order_number => order_number, :remote_uid => remote_uid)
            sales_order.inquiry.comments.create!(message: "SAP Approved", overseer: Overseer.default_approver)
            {success: 1, status: 1, message: "Order Created Successfully"} #, response: sales_order.rows.to_json
          rescue => ex
            {success: 1, status: 1, message: ex.message}
          end
        end

      when :'SAP Rejected'
        # if sales_order.status.in? ['Hold by Finance', 'SAP Rejected']
        #   {success: 1, status: 1, message: "Order Already Approved"}
        # end
        begin
          sales_order.update_attributes(:status => :'SAP Rejected')
          comment = sales_order.inquiry.comments.create!(message: comment_message, overseer: Overseer.default_approver)
          sales_order.create_rejection!(:comment => comment, :overseer => Overseer.default_approver)
          sales_order.approval.destroy!
          {success: 1, status: 1, message: "Order Rejected Successfully"}
        rescue => ex
          {success: 0, status: 0, message: ex.message}
        end
      end

    else
      {success: 0, status: 0, message: "Order Not Processed"}
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

  def comment_message_for(remote_status, remote_comment)
    [
        ['SAP Status Updated', remote_status].join(': '),
        ['Comment', remote_comment].join(': '),
    ].join('\n')
  end

  attr_accessor :params
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