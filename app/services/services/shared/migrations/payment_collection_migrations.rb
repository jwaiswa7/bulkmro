class Services::Shared::Migrations::PaymentCollectionMigrations < Services::Shared::BaseService
  def add_days_in_payment_terms
    service = Services::Shared::Spreadsheets::CsvImporter.new('payment_terms_days.csv', 'seed_files')
    service.loop(nil) do |x|
      payment_options = PaymentOption.find(x.get_column('payment_term_id'))
      payment_options.update_attributes(days: x.get_column('days'))
    end
  end

  def sales_invoice_totals
    SalesInvoice.all.each do |sales_invoice|
      sales_invoice.update_attributes!(calculated_total: sales_invoice.calculated_total) if sales_invoice.sales_order.present?
      sales_invoice.update_attributes!(calculated_total_with_tax: sales_invoice.calculated_total_with_tax) if sales_invoice.sales_order.present?
      sales_invoice.update_attributes(due_date: sales_invoice.get_due_date) if sales_invoice.sales_order.present?
    end
  end

  def update_sales_receipt
    SalesReceipt.all.each do |sr|
      if sr.metadata.class == String
        sr.metadata = JSON.parse(sr.metadata)
        sr.save
      end
      metadata_obj = sr.metadata
      currency = Currency.where(name: metadata_obj['p_amount_currency']).last
      if currency.present?
        sr.currency = currency
      end
      if sr.sales_invoice.present?
        sr.payment_type = 20
      elsif sr.company.present?
        sr.payment_type = 10
      end
      sr.payment_amount_received = metadata_obj['p_amount_received'] || 0.0
      sr.payment_received_date = metadata_obj['p_received_date']
      sr.comments = metadata_obj['p_comments']
      sr.account_id = sr.company.account_id if sr.company_id.present?
      sr.save!
    end
  end

  def new_sales_receipt
    SalesReceipt.destroy_all
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_receipts_1.csv', 'seed_files')
    service.loop(nil) do |x|
      response = JSON.parse JSON.parse(x.get_column('response'))
      if response['success'] == 1
        request = JSON.parse(x.get_column('request'))
        invoice = SalesInvoice.find_by_invoice_number(request['p_invoice_no'])
        company = request['cmp_id'].nil? ? nil : Company.find_by_remote_uid(request['cmp_id'])
        currency = Currency.find_by_name(request['p_amount_currency'])
        if !invoice.nil? || !company.nil?
          pay_amount = 0.0
          if !invoice.nil?
            pay_amount = request['p_amount_received']
            payment_type = 20
          elsif !company.nil?
            pay_amount = request['on_account']
            payment_type = 10
          end
          account = company.present? ? company.account : nil
          SalesReceipt.where(remote_reference: request['p_sap_reference_number']).first_or_create! do |sales_receipt|
            sales_receipt.assign_attributes(
              sales_invoice: invoice,
              company: company,
              account: account,
              metadata: request,
              currency: currency,
              payment_type: payment_type,
              payment_received_date: request['p_received_date'],
              payment_amount_received: pay_amount,
              payment_method: request['p_method'],
              comments: request['p_comments']
            )
          end
        end
      end
    end
  end

  def migrate_magento_sales_receipts
    payment_method = {'banktransfer' => 10, 'Cheque' => 20, 'checkmo' => 30, 'razorpay' => 40, 'free' => 50, 'roundoff' => 60, 'bankcharges' => 70, 'cash' => 80, 'creditnote' => 85, 'writeoff' => 90, 'Transfer Acct' => 95}

    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_receipts.csv', 'seed_files')
    service.loop(nil) do |x|
      sales_invoice = SalesInvoice.find_by_legacy_id(x.get_column('invoice_legacy_id'))
      sales_receipt = SalesReceipt.where(legacy_id: x.get_column('legacy_id')).first_or_initialize
      if sales_invoice.present? && sales_receipt.new_record?
        sales_receipt.sales_invoice = sales_invoice
        sales_receipt.is_legacy = true
        sales_receipt.remote_reference = x.get_column('remote_reference')
        sales_receipt.metadata = x.get_row
        sales_receipt.payment_method = payment_method[x.get_column('payment_method')]
        sales_receipt.payment_type = 20
        sales_receipt.save!

        sales_receipt.sales_receipt_rows.where(sales_invoice: sales_invoice).first_or_create!(amount_received: x.get_column('amount_received'))
        sales_receipt.update_attributes!(payment_amount_received: sales_receipt.sales_receipt_rows.sum(:amount_received))
      end
    end

    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_receipts_on_account.csv', 'seed_files')
    service.loop(nil) do |x|
      company = Company.acts_as_customer.find_by_legacy_id(x.get_column('company'))
      sales_receipt = SalesReceipt.where(legacy_id: x.get_column('legacy_id')).first_or_create!
      if sales_receipt.present?
        sales_receipt.company = company
        sales_receipt.is_legacy = true
        sales_receipt.remote_reference = x.get_column('remote_reference')
        sales_receipt.metadata = x.get_row
        sales_receipt.payment_method = payment_method[x.get_column('payment_method')]
        sales_receipt.payment_amount_received = x.get_column('amount_received')
        sales_receipt.payment_type = 10
        sales_receipt.save!
      end
    end
  end

  def migrate_sales_receipt
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_receipts_against_invoice.csv', 'seed_files')
    service.loop(nil) do |x|
      invoice = SalesInvoice.find_by_invoice_number(x.get_column('AR Invoice No'))
      company = Company.find_by_remote_uid(x.get_column('BP Code'))
      if invoice.present? && company.present? && x.get_column('Paid Amt').to_f > 0
        currency = Currency.find_by_name(x.get_column('Document Currency'))
        date = '20' + x.get_column('Payment Date').split('/').reverse.join('/')
        sales_receipt = SalesReceipt.where(remote_reference: x.get_column('Document Number')).first_or_create
        is_save = sales_receipt.update_attributes(
          company: company,
          account: company.account,
          sales_invoice: invoice,
          currency: currency,
          payment_type: :'Against Invoice',
          payment_received_date: date,
          comments: x.get_column('Remarks')
        )
        if is_save
          sales_receipt.sales_receipt_rows.where(sales_invoice: invoice).first_or_create!(amount_received: x.get_column('Paid Amt'))
          sales_receipt.update_attributes!(payment_amount_received: sales_receipt.sales_receipt_rows.sum(:amount_received))
        end
      end
    end

    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_receipts_on_account.csv', 'seed_files')
    service.loop(nil) do |x|
      company = Company.find_by_remote_uid(x.get_column('BP Code'))
      if company.present? && x.get_column('Non-Calculated Amount').to_f > 0
        currency = Currency.find_by_name(x.get_column('Document Currency'))
        date = '20' + x.get_column('Payment Date').split('/').reverse.join('/')

        sales_receipt = SalesReceipt.where(remote_reference: x.get_column('Document Number')).first_or_create!
        sales_receipt.assign_attributes(
          company: company,
          account: company.account,
          currency: currency,
          payment_type: :'On Account',
          payment_received_date: date,
          payment_amount_received: x.get_column('Non-Calculated Amount').to_f,
          comments: x.get_column('Remarks')
        )
      end
    end
  end

  def migrate_opening_balances
    service = Services::Shared::Spreadsheets::CsvImporter.new('account_company_opening_balances.csv', 'seed_files')
    service.loop(nil) do |x|
      company = Company.find_by_remote_uid(x.get_column('BP Code'))
      if company.present?
        company.update_attributes!(opening_balance: x.get_column('opening_balance'))
      end
    end
  end

  def update_payment_status_of_sales_invoice
    SalesInvoice.all.each do |si|
      if si.inquiry.present?
        invoiced_amount = si.calculated_total_with_tax
        amount_received = si.amount_received

        if invoiced_amount <= amount_received
          si.payment_status = 'Fully Paid'
        elsif amount_received == 0.0
          si.payment_status = 'Unpaid'
        elsif amount_received < invoiced_amount
          si.payment_status = 'Partially Paid'
        end
        si.save
      end
    end
  end

  def set_payment_collection_summary
    Company.acts_as_customer.all.each do |company|
      not_due_date = DateTime.now + 30.days
      invoices = company.invoices
      nd_sales_invoices = invoices.includes(:sales_receipts).where('due_date > ?', not_due_date)

      # CALCULATE NOT DUE
      no_pay_received_not_due = partially_paid_not_due = fully_paid_not_due = outstanding_partially_paid_not_due = outstanding_no_pay_received_not_due = 0
      nd_sales_invoices.each do |sales_invoice|
        if sales_invoice.payment_status == 'Fully Paid'
          fully_paid_not_due = fully_paid_not_due + sales_invoice.amount_received_against_invoice
        elsif sales_invoice.payment_status == 'Partially Paid'
          partially_paid_not_due = partially_paid_not_due + sales_invoice.amount_received_against_invoice
          outstanding_partially_paid_not_due = outstanding_partially_paid_not_due + (sales_invoice.calculated_total_with_tax - sales_invoice.amount_received_against_invoice)
        elsif sales_invoice.payment_status == 'Unpaid'
          no_pay_received_not_due = no_pay_received_not_due + sales_invoice.amount_received_against_invoice
          outstanding_no_pay_received_not_due = outstanding_no_pay_received_not_due + (sales_invoice.calculated_total_with_tax - sales_invoice.amount_received_against_invoice)
        end
      end

      # CALCULATE AMOUNT DUE IN 01 - 07 DAYS
      due_date_after_1 = DateTime.now + 1
      due_date_after_7 = DateTime.now + 7
      due_in_1_to_7_days_invoices = invoices.includes(:sales_receipts).where('due_date >= ? AND due_date <= ?', due_date_after_1, due_date_after_7)
      amount_1_to_7_nd = 0.0
      due_in_1_to_7_days_invoices.each do |invoice|
        amount_1_to_7_nd += (invoice.calculated_total_with_tax - invoice.amount_received_against_invoice)
      end
      amount_1_to_7_nd = (amount_1_to_7_nd < 0) ? 0.0 : amount_1_to_7_nd

      # CALCULATE AMOUNT DUE IN 08 - 15 DAYS
      due_date_after_15 = DateTime.now + 15
      due_in_8_to_15_days_invoices = invoices.includes(:sales_receipts).where('due_date > ? AND due_date <= ?', due_date_after_7, due_date_after_15)
      amount_8_to_15_nd = 0.0
      due_in_8_to_15_days_invoices.each do |invoice|
        amount_8_to_15_nd += (invoice.calculated_total_with_tax - invoice.amount_received_against_invoice)
      end
      amount_8_to_15_nd = (amount_8_to_15_nd < 0) ? 0.0 : amount_8_to_15_nd

      # CALCULATE AMOUNT DUE IN 16 - 30 DAYS
      due_date_after_30 = DateTime.now + 30
      due_in_16_to_30_days_invoices = invoices.includes(:sales_receipts).where('due_date > ? AND due_date <= ?', due_date_after_15, due_date_after_30)
      amount_16_to_30_nd = 0.0
      due_in_16_to_30_days_invoices.each do |invoice|
        amount_16_to_30_nd += (invoice.calculated_total_with_tax - invoice.amount_received_against_invoice)
      end
      amount_16_to_30_nd = (amount_16_to_30_nd < 0) ? 0.0 : amount_16_to_30_nd


      # CALCULATE AMOUNT DUE IN 16 - 30 DAYS
      due_in_16_to_30_days_invoices = invoices.includes(:sales_receipts).where('due_date > ?', due_date_after_30)
      amount_more_than_30_nd = 0.0
      due_in_16_to_30_days_invoices.each do |invoice|
        amount_more_than_30_nd += (invoice.calculated_total_with_tax - invoice.amount_received_against_invoice)
      end
      amount_more_than_30_nd = (amount_more_than_30_nd < 0) ? 0.0 : amount_more_than_30_nd


      # CALCULATE OVERDUE
      overdue_no_pay_received = overdue_partially_paid = overdue_fully_paid = outstanding_overdue_partially_paid = outstanding_overdue_no_pay_received = 0
      od_sales_invoices = invoices
      # od_sales_invoices = invoices.includes(:sales_receipts).where('due_date < ?', Time.now)
      od_sales_invoices.each do |sales_invoice|
        # all invoiced amount added as outstaningif sales_invoice.payment_status == 'Partially Paid'
        if sales_invoice.payment_status == 'Partially Paid'
          outstanding_overdue_partially_paid = sales_invoice.calculated_total_with_tax
        elsif sales_invoice.payment_status == 'Unpaid'
          outstanding_overdue_no_pay_received = sales_invoice.calculated_total_with_tax
        end
        sales_invoice.sales_receipts.each do |sales_receipt|
          if sales_receipt.payment_received_date.present? && sales_receipt.payment_received_date > sales_invoice.due_date
            if sales_invoice.payment_status == 'Fully Paid'
              overdue_fully_paid += sales_receipt.payment_amount_received
            elsif sales_invoice.payment_status == 'Partially Paid'
              overdue_partially_paid += sales_receipt.payment_amount_received
              outstanding_overdue_partially_paid -= sales_receipt.payment_amount_received
            elsif sales_invoice.payment_status == 'Unpaid'
              overdue_no_pay_received += sales_invoice.calculated_total_with_tax
            end
          else
            if sales_invoice.payment_status == 'Partially Paid'
              outstanding_overdue_partially_paid -= sales_receipt.payment_amount_received
            end
          end
        end
      end


      # CALCULATE AMOUNT OVERDUE FROM 01 - 30 Days
      due_date_before_30 = DateTime.now - 30
      due_date_before_1 = DateTime.now -1
      overdue_before_1_30_days_invoices = invoices.includes(:sales_receipts).where(due_date: due_date_before_30..due_date_before_1)
      amount_1_to_30_od = 0.0
      overdue_before_1_30_days_invoices.each do |invoice|
        amount_1_to_30_od += (invoice.calculated_total_with_tax - invoice.amount_received_against_invoice)
      end
      amount_1_to_30_od = (amount_1_to_30_od < 0) ? 0.0 : amount_1_to_30_od


      # CALCULATE AMOUNT OVERDUE FROM 31 - 60 Days
      due_date_before_60 = DateTime.now - 60
      overdue_before_31_60_days_invoices = invoices.includes(:sales_receipts).where(due_date: due_date_before_60..due_date_before_30)
      amount_31_to_60_od = 0.0
      overdue_before_31_60_days_invoices.each do |invoice|
        amount_31_to_60_od += (invoice.calculated_total_with_tax - invoice.amount_received_against_invoice)
      end
      amount_31_to_60_od = (amount_31_to_60_od < 0) ? 0.0 : amount_31_to_60_od


      # CALCULATE AMOUNT OVERDUE FROM 61 - 90 Days
      due_date_before_90 = DateTime.now - 90
      overdue_before_61_90_days_invoices = invoices.includes(:sales_receipts).where(due_date: due_date_before_90..due_date_before_60)
      amount_61_to_90_od = 0.0
      overdue_before_61_90_days_invoices.each do |invoice|
        amount_61_to_90_od += (invoice.calculated_total_with_tax - invoice.amount_received_against_invoice)
      end
      amount_61_to_90_od = (amount_61_to_90_od < 0) ? 0.0 : amount_61_to_90_od


      # CALCULATE AMOUNT OVERDUE MORE THAN 90 Days
      overdue_before_more_90_days_invoices = invoices.includes(:sales_receipts).where('due_date < ? ', due_date_before_90)
      amount_overdue_more_90 = 0.0
      overdue_before_more_90_days_invoices.each do |invoice|
        amount_overdue_more_90 += (invoice.calculated_total_with_tax - invoice.amount_received_against_invoice)
      end
      amount_overdue_more_90 = (amount_overdue_more_90 < 0) ? 0.0 : amount_overdue_more_90

      total_amount_received = company.sales_receipts.sum(:payment_amount_received)


      payment_collection = PaymentCollection.find_or_create_by(company: company)
      payment_collection.update_attributes(
        account_id: company.account_id,
        amount_received_fp_nd: fully_paid_not_due,
        amount_received_pp_nd: partially_paid_not_due,
        amount_received_npr_nd: no_pay_received_not_due,
        amount_received_fp_od: overdue_fully_paid,
        amount_received_pp_od: overdue_partially_paid,
        amount_received_npr_od: overdue_no_pay_received,

        amount_outstanding_pp_nd: outstanding_partially_paid_not_due,
        amount_outstanding_npr_nd: outstanding_no_pay_received_not_due,
        amount_outstanding_pp_od: outstanding_overdue_partially_paid,
        amount_outstanding_npr_od: outstanding_overdue_no_pay_received,
        amount_received_on_account: company.sales_receipts.with_amount_on_account.sum(:payment_amount_received),
        amount_received_against_invoice: company.sales_receipts.with_amount_by_invoice.sum(:payment_amount_received),
        total_amount_received: total_amount_received,
        amount_outstanding: invoices.sum(:calculated_total_with_tax) - total_amount_received,

        amount_1_to_30_od: amount_1_to_30_od,
        amount_31_to_60_od: amount_31_to_60_od,
        amount_61_to_90_od: amount_61_to_90_od,
        amount_more_90_od: amount_overdue_more_90,
        amount_1_to_7_nd: amount_1_to_7_nd,
        amount_8_to_15_nd: amount_8_to_15_nd,
        amount_15_to_30_nd: amount_16_to_30_nd,
        amount_more_30_nd: amount_more_than_30_nd,
      )
    end
  end
end
