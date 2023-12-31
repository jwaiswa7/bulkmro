class Services::Shared::Migrations::InvoiceDataImport < Services::Shared::Migrations::Migrations
	def import_invoice_data
		service = Services::Shared::Spreadsheets::CsvImporter.new('invoice_data.csv', 'seed_files_3')
		@dup_invoice_number = 0
		service.loop(nil) do |x|
			invoice_number = x.get_column('Invoice number')
			state = x.get_column('State')
			sku = x.get_column('SKU')
			product_id = x.get_column('product_id')
			description = x.get_column('description')
			qty = x.get_column('qty')
			price = x.get_column('Price')
			tax_code = x.get_column('tax code')
			row_total = x.get_column('row_total')
			tax_amount = x.get_column('tax amount')
      row_total_incl_tax = x.get_column('row_total_incl_tax')
			order_id = x.get_column('order_id')
			bill_from = x.get_column('bill_from')
			created_at = x.get_column('created_at')
			mis_date = x.get_column('MIS date')
			billing_address_id = x.get_column('Billing address id')
			shipping_address_id = x.get_column('Shipping address id')
      
      sales_invoice = SalesInvoice.find_by(invoice_number: invoice_number.to_i)
      
			unless sales_invoice.present?
				sales_order = SalesOrder.find_by(order_number: order_id.to_i)

				item_hash = Hash.new
				item_hash["sku"] = sku.to_s
				item_hash["product_id"] = product_id.to_s
				item_hash["description"] = description.to_s
				item_hash["qty"] = qty.to_f
				item_hash["price"] = price.to_f
				item_hash["tax_code"] = tax_code.to_i
				item_hash["row_total"] = row_total.to_f
				item_hash["base_row_total"] = row_total.to_f
				item_hash["tax_amount"] = tax_amount.to_f
				item_hash["base_tax_amount"] = tax_amount.to_f
				item_hash["row_total_incl_tax"] = row_total_incl_tax.to_f
				item_hash["base_row_total_incl_tax"] = row_total_incl_tax.to_f

				if @dup_invoice_number == invoice_number
					sales_invoice.metadata["ItemLine"] << item_hash
				  sales_invoice.save(validate: false)
				else
					invoice = SalesInvoice.new
					invoice.sales_order_id = sales_order.id if sales_order.present?
					invoice.invoice_number = invoice_number.to_i
					invoice.metadata = Hash.new
					invoice.metadata["state"] = state.to_s
					invoice.metadata["ItemLine"] = []
					invoice.metadata["ItemLine"] << item_hash
					invoice.metadata["order_id"] = order_id.to_s
					invoice.metadata["bill_from"] = bill_from.to_s
					invoice.metadata["created_at"] = created_at.to_s
					invoice.created_at = DateTime.parse created_at.to_s
					invoice.mis_date =  Date.parse mis_date.to_s
					invoice.metadata["billing_address_id"] = billing_address_id.to_i
					invoice.metadata["shipping_address_id"] = shipping_address_id.to_i
				  invoice.save(validate: false)
					@dup_invoice_number = invoice_number
				end
			end
		end
	end

	def import_credit_note_data
		service = Services::Shared::Spreadsheets::CsvImporter.new('credit_note_data.csv', 'seed_files_3')
		service.loop(nil) do |x|
			memo_number = x.get_column('AR Credit Memo')
			memo_date = x.get_column('AR Credit Memo Date')
			memo_amount = x.get_column('Credit Memo Amount')
			invoice_number = x.get_column('Invoice')

			sales_invoice = SalesInvoice.find_by_invoice_number(invoice_number.to_i)
      credit_note = CreditNote.find_by(memo_number: memo_number.to_i)

			unless credit_note.present?
				new_credit_note = CreditNote.new
				new_credit_note.memo_number = memo_number.to_i
				new_credit_note.memo_date = DateTime.parse memo_date.to_s
				new_credit_note.memo_amount = memo_amount.to_f
				new_credit_note.sales_invoice_id = sales_invoice.id if sales_invoice.present?
				new_credit_note.save(validate: false)
			end
		end
	end
end
