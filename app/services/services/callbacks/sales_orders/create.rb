class Services::Overseers::SalesOrders::Create < Services::Shared::BaseService

  def initialize(params)
    @params = params
  end

  def call
    legacy_id = params['U_MgntDocID']
    remote_status = params['Status']
    remote_comment = params['comment']
    draft_uid = params['DocEntry']
    order_number = params['DocNum']
    comment_message = comment_message_for(remote_status, remote_comment)
    sales_order = SalesOrder.find_by_doc_number(draft_uid) || SalesOrder.find_by_legacy_id(legacy_id)

    if legacy_id && remote_status && draft_uid && sales_order.present? && sales_order.approved? && !sales_order.rejected?
      case to_local_status(remote_status)
      when :'approved'
        return if sales_order.approved?

        sales_order.update_attributes(:status => :'approved', :order_number => order_number)
        sales_order.inquiry.comments.create!(message: comment_message, overseer: Overseer.default_approver)
      when :'SAP Rejected'
        return if sales_order.status.in? ['Hold by Finance', 'SAP Rejected']

        sales_order.update_attributes(:status => :'SAP Rejected')
        comment = sales_order.inquiry.comments.create!(message: comment_message, overseer: Overseer.default_approver)
        sales_order.create_rejection!(:comment => comment, :overseer => Overseer.default_approver)
        sales_order.approval.destroy!
      end
    end

    sales_order
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