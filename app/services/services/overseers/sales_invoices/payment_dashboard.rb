class Services::Overseers::SalesInvoices::PaymentDashboard < Services::Shared::BaseService

  def initialize(parent = nil)
    if parent.present?
      @payment_collection = parent.payment_collections
    else
      @payment_collection = PaymentCollection.all
    end

    @color = ['color-light-blue','dark','primary','success','warning','primary','info']

    @summery_data = {
        total_invoice: {
            full_paid_nt_due: {name: 'Full Paid (Not Due)',value: 0 , color: color.sample},
            partial_paid_nt_due: {name: 'Partial Paid (Not Due)' ,value: 0 , color: color.sample},
            no_payment_nt_due: {name: 'No Payment Received (Not Due)' ,value: 0 , color: color.sample},
            full_paid_over_due: {name: 'Full Paid (Overdue)' ,value: 0 , color: color.sample},
            partial_paid_over_due: {name: 'Partial Paid (Overdue)' ,value: 0 , color: color.sample},
            no_payment_over_due: {name: 'No Payment Received (Overdue)' ,value: 0 , color: color.sample}
        },
        total_outstanding: {
            partial_paid_nt_due: {name: 'Partial Paid (Not Due)',value: 0 , color: color.sample},
            no_payment_nt_due: {name:  'No Payment Received (Not Due)',value: 0, color: color.sample},
            partial_paid_over_due: {name:  'Partial Paid (Overdue)',value: 0, color: color.sample},
            no_payment_over_due: {name: 'No Payment Received (Overdue)',value: 0 , color: color.sample},
            on_account: {name: 'On Account',value: 0 , color: color.sample}
        }
    }
  end

  def call
    if payment_collection.present?
      summery_data[:total_invoice][:full_paid_nt_due][:value] = payment_collection.sum(:amount_received_fp_nd )
      summery_data[:total_invoice][:partial_paid_nt_due][:value] = payment_collection.sum(:amount_received_pp_nd)
      summery_data[:total_invoice][:no_payment_nt_due][:value] =  payment_collection.sum(:amount_received_npr_nd)
      summery_data[:total_invoice][:full_paid_over_due][:value] = payment_collection.sum(:amount_received_fp_od )
      summery_data[:total_invoice][:partial_paid_over_due][:value] = payment_collection.sum(:amount_received_pp_od)
      summery_data[:total_invoice][:no_payment_over_due][:value] =  payment_collection.sum(:amount_received_npr_od)

      summery_data[:total_outstanding][:partial_paid_nt_due][:value] =   payment_collection.sum(:amount_outstanding_pp_nd)
      summery_data[:total_outstanding][:no_payment_nt_due][:value] =  payment_collection.sum(:amount_outstanding_npr_nd)
      summery_data[:total_outstanding][:partial_paid_over_due][:value] = payment_collection.sum(:amount_outstanding_pp_od)
      summery_data[:total_outstanding][:no_payment_over_due][:value] =  payment_collection.sum(:amount_outstanding_npr_od)
      summery_data[:total_outstanding][:on_account][:value] =  payment_collection.sum(:amount_received_on_account)
    end
  end

  attr_accessor :summery_data, :payment_collection, :color
end