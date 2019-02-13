class MultipleFilePresenceValidator < ActiveModel::Validator
  def validate(record)
    if options[:attachments].blank? || !record.send(attachments).attached?
      record.errors.add(attachments, "must be attached")
    end
  end

  def attachments
    options[:attachments].to_s
  end
end
