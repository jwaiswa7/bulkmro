class Services::Overseers::SalesInvoices::AgeingReport < Services::Shared::BaseService

  def initialize(parent = nil)
    if parent.present?
      @payment_collection = parent.payment_collections
    else
      @payment_collection = PaymentCollection.all
    end

    @color = ['color-light-blue','dark','primary','success','warning','primary','info']

    @summery_data = {
        company_ageing_report: {
            total_invoice: {name: 'Total Invoice',value: 0 , color: color.sample},
            paid_amount: {name: 'Paid Amount' ,value: 0 , color: color.sample},
            overdue_amount: {name: 'Amount (Overdue)' ,value: 0 , color: color.sample},
            amount_1_to_30_od:{name: '1-30 Days', value: 0 , color: color.sample},
            amount_31_to_60_od:{name: '31-60 Days', value: 0 , color: color.sample},
            amount_61_to_90_od:{name: '61-90 Days', value: 0 , color: color.sample},
            amount_more_90_od:{name: '> 90 Days', value: 0 , color: color.sample},
            no_payment_nt_due: {name: 'Amount (Not Due)' ,value: 0 , color: color.sample},
            amount_1_to_7_nd:{name: '1-7 Days', value: 0 , color: color.sample},
            amount_8_to_15_nd:{name: '8-15 Days', value: 0 , color: color.sample},
            amount_15_to_30_nd:{name: '16-30 Days', value: 0 , color: color.sample},
            amount_more_30_nd:{name: '>30 Days', value: 0 , color: color.sample},
        }
    }
  end

  def call
    if payment_collection.present?
      summery_data[:company_ageing_report][:total_invoice][:value] = payment_collection.sum(:amount_received_fp_nd )
      summery_data[:company_ageing_report][:paid_amount][:value] = payment_collection.sum(:amount_received_pp_nd)
      summery_data[:company_ageing_report][:overdue_amount][:value] =  payment_collection.sum(:amount_received_npr_nd)
      summery_data[:company_ageing_report][:amount_1_to_30_od][:value] =  payment_collection.sum(:amount_1_to_30_od)
      summery_data[:company_ageing_report][:amount_31_to_60_od][:value] =  payment_collection.sum(:amount_31_to_60_od)
      summery_data[:company_ageing_report][:amount_61_to_90_od][:value] =  payment_collection.sum(:amount_61_to_90_od)
      summery_data[:company_ageing_report][:amount_more_90_od][:value] =  payment_collection.sum(:amount_more_90_od)
      summery_data[:company_ageing_report][:amount_1_to_7_nd][:value] =  payment_collection.sum(:amount_1_to_7_nd)
      summery_data[:company_ageing_report][:amount_8_to_15_nd][:value] =  payment_collection.sum(:amount_8_to_15_nd)
      summery_data[:company_ageing_report][:amount_15_to_30_nd][:value] =  payment_collection.sum(:amount_15_to_30_nd)
      summery_data[:company_ageing_report][:amount_more_30_nd][:value] =  payment_collection.sum(:amount_more_30_nd)
    end
  end

  attr_accessor :summery_data, :payment_collection, :color
end