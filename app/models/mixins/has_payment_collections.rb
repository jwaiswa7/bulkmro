module Mixins::HasPaymentCollections
  extend ActiveSupport::Concern

  def total_amount_received
    self.amount_received_against_invoice + self.amount_received_on_account
  end

  def amount_received_on_account
    self.sales_receipts.where(:payment_type => :'On Account').sum(:payment_amount_received)
  end

  def amount_received_against_invoice
    amount = 0
    invoices = self.invoices.includes(:sales_receipts).where('sales_invoices.mis_date >= ?', '01-04-2018')
    invoices.each do |sales_invoice|
      amount += sales_invoice.sales_receipts.where(:payment_type => :'Against Invoice').sum(:payment_amount_received)
    end
    amount
  end

  def total_amount_due
    self.invoices.where('sales_invoices.mis_date >= ? AND sales_invoices.status != ?', '01-04-2018', 3).sum(&:calculated_total_with_tax)
  end

  def total_amount_outstanding
    amount = self.total_amount_due - self.total_amount_received
    (amount <  0.0) ? 0.0 : amount
  end

  def amount_overdue_outstanding
    # invoice date is crossed and payment is not received yet
    amount = 0.0
    invoices = self.invoices.includes(:sales_receipts).where('sales_invoices.mis_date >= ?', '01-04-2018')
    invoices.each do |sales_invoice|
      outstanding_amount = sales_invoice.calculated_total_with_tax
      due_date = sales_invoice.due_date
      todays_date = Date.today
      # sales_receipts = sales_invoice.sales_receipts
      sales_invoice.sales_receipts.each do |sales_receipt|
        if (sales_receipt.payment_received_date < due_date ) || (sales_receipt.payment_received_date < todays_date)
          outstanding_amount -= sales_receipt.payment_amount_received
        end
      end
      amount += outstanding_amount
    end
    amount
  end
end
