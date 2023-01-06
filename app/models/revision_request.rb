class RevisionRequest < ApplicationRecord
  belongs_to :sales_quote
  belongs_to :contact

  has_many :email_messages

  has_many_attached :files

  validates :reason, :required_changes, presence: true

  after_create_commit :send_email

  after_create_commit :update_inquiry

  validates_with MultipleFileValidator, attachments: :files, file_size_in_megabytes: 2


  def inquiry
    sales_quote.inquiry
  end


  private

    # Updates the inquiry status to revision requested once the revision request has been made
    def update_inquiry
      inquiry = sales_quote.inquiry
      inquiry.status = 23
      inquiry.save(validate: false)
    end

    # Sends an email once the revision request has been made
    def send_email
      inquiry = sales_quote.inquiry

      email_message = email_messages.build(
        contact: contact,
        inquiry: inquiry,
        revision_request: self,
        from: 'itops@bulkmro.com',
        email_type: 90,
        subject: "Revision request submitted for inquiry ##{inquiry.id}",
        to: [inquiry.inside_sales_owner.email, inquiry.outside_sales_owner.email, inquiry.sales_manager.email].uniq.join(',')
      )

      email_message.body = RevisionRequestMailer.request_submitted(email_message, self, inquiry).body.raw_source

      files.each do |original_file|
        email_message.files.attach(io: StringIO.new(original_file.download),
                                 filename: original_file.filename,
                                 content_type: original_file.content_type)
      end

      if email_message.save
        RevisionRequestMailer.send_submited_request(email_message).deliver_now
      end
    end
end