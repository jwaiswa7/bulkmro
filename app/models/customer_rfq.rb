class CustomerRfq < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :billing_address, foreign_key: :billing_address_id, class_name: 'Address', required: false
  belongs_to :shipping_address, foreign_key: :shipping_address_id, class_name: 'Address', required: false
  belongs_to :contact, required: false

  has_many_attached :files

  has_many :email_messages, dependent: :destroy
  has_many :inquiry_products, through: :inquiry
  accepts_nested_attributes_for :inquiry_products, reject_if: lambda {|attributes| attributes['product_id'].blank? && attributes['id'].blank?}, allow_destroy: true

  after_commit :send_email_notification, on: :create

  update_index('customer_rfqs#customer_rfq') {self}

  scope :with_includes, -> { includes(:created_by, :updated_by, :inquiry) }

  private

    def send_email_notification
      return if contact.nil?

      email_message = email_messages.build(contact: contact, inquiry: inquiry, company: contact.company)
      email_message.assign_attributes(
        subject: 'New RFQ has been created',
        body: CustomerRfqMailer.rfq_created(email_message).body.raw_source,
        from: 'itops@bulkmro.com',
        to: contact.email
      )

      if email_message.save
        CustomerRfqMailer.rfq_created(email_message).deliver_now
      end
    end
end
