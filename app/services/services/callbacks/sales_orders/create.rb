class Services::Callbacks::SalesOrders::Create < Services::Callbacks::Shared::BaseCallback
  def call
    sprint_order_id = params['U_MgntDocID']
    remote_status = params['Status']
    remote_comment = params['comment']
    remote_uid = params['DocEntry']
    order_number = params['DocNum']
    comment_message = [
        ['SAP Status Updated', to_local_status(remote_status)].join(': '),
        ['Comment', remote_comment].join(': '),
    ].join(' | ')

    if sprint_order_id.blank?
      return_response('Order not found.', 0)
    else
      sales_order = SalesOrder.find(sprint_order_id)

      if sales_order.present?
        case to_local_status(remote_status)
        when :'Approved'
          if sales_order.remote_status.blank?
            begin
              sales_order.update_attributes(remote_status: :'Supplier PO: Request Pending', status: :'Approved', mis_date: Date.today, order_number: order_number, remote_uid: remote_uid)
              Services::Overseers::Inquiries::UpdateStatus.new(sales_order, :order_won).call
              sales_order.inquiry.comments.create!(message: 'SAP Approved', overseer: Overseer.default_approver)
              sales_order.serialized_pdf.attach(io: File.open(RenderPdfToFile.for(sales_order)), filename: sales_order.filename)
              sales_order.update_index
              return_response('Order Created Successfully')
            rescue => e
              return_response(e.message, 0)
            end
          else
            return_response('Order Already Synced : ' + sales_order.remote_status)
          end
        when :'SAP Rejected'
          begin
            sales_order.update_attributes(status: :'SAP Rejected')
            comment = InquiryComment.where(message: comment_message, inquiry: sales_order.inquiry, created_by: Overseer.default_approver, updated_by: Overseer.default_approver, sales_order: sales_order).first_or_create! if sales_order.inquiry.present?
            Services::Overseers::Inquiries::UpdateStatus.new(sales_order, :sap_rejected).call
            sales_order.create_rejection!(comment: comment, overseer: Overseer.default_approver)
            sales_order.approval.destroy! if sales_order.approval.present?
            sales_order.update_index
            return_response('Order Rejected Successfully')
          rescue => e
            return_response(e.message, 0)
          end
        end
      else
        return_response('Order Not Processed', 0)
      end
    end
  end

  def to_local_status(remote_status)
    case remote_status
    when '1'
      :'Approved'
    when '2'
      :'SAP Rejected'
    when '3'
      :'SAP Rejected'
    end
  end
end
