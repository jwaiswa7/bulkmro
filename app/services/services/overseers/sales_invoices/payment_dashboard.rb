class Services::Overseers::SalesInvoices::PaymentDashboard < Services::Shared::BaseService

  def initialize(parent = nil)
    if parent.nil?
      @invoices = SalesInvoice.not_cancelled_invoices
    else
      @invoices = parent.invoices.not_cancelled_invoices
    end

    color = ['color-light-blue','dark','primary','success','warning','primary','info']
    @summery_data = {
        total_invoice: {
            full_paid_nt_due: {name: 'Full Paid (Not Due)',value: 0 ,total_count: 0, color: color.sample},
            partial_paid_nt_due: {name: 'Partial Paid (Not Due)' ,value: 0,total_count: 0, color: color.sample},
            no_payment_nt_due: {name: 'No Payment Received (Not Due)' ,value: 0 ,total_count: 0, color: color.sample},
            full_paid_over_due: {name: 'Full Paid (Overdue)' ,value: 0 ,total_count: 0, color: color.sample},
            partial_paid_over_due: {name: 'Partial Paid (Overdue)' ,value: 0 ,total_count: 0, color: color.sample},
            no_payment_over_due: {name: 'No Payment Received (Overdue)' ,value: 0 ,total_count: 0, color: color.sample}
        },
        total_outstanding: {
            partial_paid_nt_due: {name: 'Partial Paid (Not Due)',value: 0 ,total_count: 0, color: color.sample},
            no_payment_nt_due: {name:  'No Payment Received (Not Due)',value: 0 ,total_count: 0, color: color.sample},
            partial_paid_over_due: {name:  'Partial Paid (Overdue)',value: 0 ,total_count: 0, color: color.sample},
            no_payment_over_due: {name: 'No Payment Received (Overdue)',value: 0 ,total_count: 0, color: color.sample},
            # on_account: {name: 'On Account',value: @account.sales_receipts.with_amount_on_account.sum(&:payment_amount_received) ,total_count: 0, color: color.sample,'total_no': @account.sales_receipts.with_amount_on_account.count }
            on_account: {name: 'On Account',value: 0 ,total_count: 0, color: color.sample,'total_no': 0}
        }
    }

  end

  def call


    invoices.each do |invoice|
      outstanding_amt =  invoice.calculated_total_with_tax - invoice.sales_receipts.sum(&:payment_amount_received)

      if outstanding_amt == 0.0
        summery_data[:total_invoice][:full_paid_nt_due][:value] += invoice.calculated_total_with_tax
        summery_data[:total_invoice][:full_paid_over_due][:value] += invoice.calculated_total_with_tax
        summery_data[:total_invoice][:full_paid_nt_due][:total_count] +=  1
        summery_data[:total_invoice][:full_paid_over_due][:total_count] +=  1
      elsif outstanding_amt == invoice.calculated_total_with_tax
        summery_data[:total_invoice][:no_payment_nt_due][:value] += invoice.calculated_total_with_tax
        summery_data[:total_outstanding][:no_payment_nt_due][:value] += invoice.calculated_total_with_tax
        summery_data[:total_invoice][:no_payment_over_due][:value] += invoice.calculated_total_with_tax
        summery_data[:total_outstanding][:no_payment_over_due][:value] += invoice.calculated_total_with_tax
        summery_data[:total_invoice][:no_payment_nt_due][:total_count] +=  1
        summery_data[:total_outstanding][:no_payment_nt_due][:total_count] +=  1
        summery_data[:total_invoice][:no_payment_over_due][:total_count] +=  1
        summery_data[:total_outstanding][:no_payment_over_due][:total_count] +=  1
      else
        summery_data[:total_invoice][:partial_paid_nt_due][:value] += invoice.calculated_total_with_tax
        summery_data[:total_outstanding][:partial_paid_nt_due][:value] += outstanding_amt
        summery_data[:total_invoice][:partial_paid_over_due][:value] += invoice.calculated_total_with_tax
        summery_data[:total_outstanding][:partial_paid_over_due][:value] += outstanding_amt
        summery_data[:total_invoice][:partial_paid_nt_due][:total_count] +=  1
        summery_data[:total_outstanding][:partial_paid_nt_due][:total_count] +=  1
        summery_data[:total_invoice][:partial_paid_over_due][:total_count] +=  1
        summery_data[:total_outstanding][:partial_paid_over_due][:total_count] +=  1
      end
    end
  end

  attr_accessor :invoices, :summery_data
end