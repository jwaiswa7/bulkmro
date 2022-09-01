class Services::Shared::Migrations::InvoiceDataImport < Services::Shared::Migrations::Migrations
	def call
		service = Services::Shared::Spreadsheets::CsvImporter.new('invoice_data.csv', 'seed_files_3')
		service.loop(nil) do |x|
			sales_order_id = x.get_column('Sales Order ID')
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
      
			invoice = SalesInvoice.new
			invoice.sales_order_id = sales_order_id.to_i
			invoice.invoice_number = invoice_number.to_i
			invoice.metadata["state"] = state.to_s
			invoice.metadata["ItemLine"][0]["sku"] = sku.to_s
			invoice.metadata["ItemLine"][0]["product_id"] = product_id.to_s
			invoice.metadata["ItemLine"][0]["description"] = description.to_s
			invoice.metadata["ItemLine"][0]["qty"] = qty.to_f
			invoice.metadata["ItemLine"][0]["price"] = price.to_f
			invoice.metadata["ItemLine"][0]["tax_code"] = tax_code.to_i
			invoice.metadata["ItemLine"][0]["row_total"] = row_total.to_f
			invoice.metadata["ItemLine"][0]["base_row_total"] = row_total.to_f
			invoice.metadata["ItemLine"][0]["tax_amount"] = tax_amount.to_f
			invoice.metadata["ItemLine"][0]["base_tax_amount"] = tax_amount.to_f
			invoice.metadata["ItemLine"][0]["row_total_incl_tax"] = row_total_incl_tax.to_f
			invoice.metadata["ItemLine"][0]["base_row_total_incl_tax"] = row_total_incl_tax.to_f
			invoice.metadata["order_id"] = order_id.to_s
			invoice.metadata["bill_from"] = bill_from.to_s
			invoice.metadata["created_at"] = created_at.to_s
			invoice.created_at = DateTime.parse created_at.to_s
			invoice.mis_date =  Date.parse mis_date.to_s
			invoice.metadata["billing_address_id"] = billing_address_id.to_i
			invoice.metadata["shipping_address_id"] = shipping_address_id.to_i
			invoice.save(validate: false)
			
		end
	end
end
