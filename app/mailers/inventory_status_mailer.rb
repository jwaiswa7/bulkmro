class InventoryStatusMailer < ApplicationMailer
	default template_path: "mailers/#{self.name.underscore}"

	def send_inventory_status_to_customer
		@overseer = Overseer.find 202
		@company = Company.find 11420
		@customer_products = @company.customer_products
		@contact = Contact.find 15589
		@bhiwandi_warehouse = Warehouse.find 'LGVfay'
    @chennai_warehouse = Warehouse.find 'OxGf6R'
		body = render_to_string template: "mailers/inventory_status_mailer/inventory_status"
		@email_message = EmailMessage.create(
			overseer_id: @overseer.id,
			from: @overseer.email,
			to: @overseer.email,
			subject: "Inventory Status Update as on #{Date.today} .",
			body: body,
			company_id: @company.id,
			email_type: 60	
		)
		standard_email(@email_message)
		email = htmlized_email(@email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
	end
end
