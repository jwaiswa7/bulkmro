class FilePresenceValidator < ActiveModel::Validator
  def validate(record)
    if options[:attachment].blank? || !record.send(attachment).attached?
      record.errors.add(:image, "must be attached")
    end
  end

  def attachment
    options[:attachment].to_s
  end
end