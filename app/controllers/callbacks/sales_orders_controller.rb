class Callbacks::SalesOrdersController < Callbacks::BaseController
  #request params: {"U_MgntDocID":"942","Status":"1","comment":"","DocNum":"10300008","DocEntry":"609","UserEmail":"35","SapReject":""}
  def create
    legacy_id = params['U_MgntDocID']
    status = params['Status']
    draft_uid = params['DocEntry']
    comment = params['comment']

    if legacy_id && status && draft_uid
      sales_order = SalesOrder.find_by_doc_number(draft_uid) || SalesOrder.find_by_legacy_id!(legacy_id)

      ActiveRecord::Base.transaction do
        case status
        when '1'
          return if sales_order.status == 'approved'
          sales_order.update_attributes(:status => :'approved', :order_number => params['DocNum'])

          message = [
              ['SAP Status Updated', sales_order.status].join(': '),
              ['Comment', comment].join(': '),
          ].join('\n')

          sales_order.inquiry.comments.create!(message: message, overseer: Overseer.default_approver)
        when '2'
          return if sales_order.status == 'SAP Rejected'
          sales_order.update_attributes(:status => :'SAP Rejected')

          message = [
              ['SAP Status Updated', sales_order.status].join(': '),
              ['Comment', comment].join(': '),
          ].join('\n')

          comment = sales_order.inquiry.comments.create!(message: message, overseer: Overseer.default_approver)
          sales_order.create_rejection!(:comment => comment, :overseer => Overseer.default_approver)
          sales_order.approval.destroy!
        when '3'
          return if sales_order.status.in? ['Hold by Finance', 'SAP Rejected']
          sales_order.update_attributes(:status => :'Hold by Finance')

          message = [
              ['SAP Status Updated', sales_order.status].join(': '),
              ['Comment', comment].join(': '),
          ].join('\n')

          comment = sales_order.inquiry.comments.create!(message: message, overseer: Overseer.default_approver)
          sales_order.create_rejection!(:comment => comment, :overseer => Overseer.default_approver)
          sales_order.approval.destroy!
        else
          raise
        end if sales_order.present? && sales_order.approved? && !sales_order.rejected?
      end
    end

    render json: format_response(1, 'SalesOrder updated successfully.', {}), status: :ok
  end

  #request params: {"increment_id":"2001656","sap_order_status":"30","comment":"","DocNum":"2001656","DocEntry":"2169","UserEmail":"35","SapReject":""}
  def update
    order_number = params['increment_id']
    remote_status = params['sap_order_status'].to_i
    new_remote_status = SalesOrder.remote_statuses[remote_status]

    if order_number && remote_status
      sales_order = SalesOrder.find_by_order_number!(params['increment_id'])

      message = [
          ["SAP Status Updated: ", sales_order.remote_status].join
      ].join('\n')

      ActiveRecord::Base.transaction do
        if remote_status == 30
          comment = InquiryComment.create(message: message, inquiry: sales_order.inquiry, overseer: Overseer.default_approver)
          sales_order.create_rejection!(:comment => comment, :overseer => Overseer.default_approver)
          sales_order.approval.destroy!
        elsif new_remote_status != sales_order.remote_status
          sales_order.update_attributes(:remote_status => new_remote_status)
          InquiryComment.create(message: message, inquiry: sales_order.inquiry, overseer: Overseer.default_approver)
        end
      end
    end

    render json: format_response(1, 'SalesOrder updated successfully.', {}), status: :ok
  end

end