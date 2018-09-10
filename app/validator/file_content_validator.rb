class FileContentValidator < ActiveModel::Validator
  def validate(record)
    if record.attached? && !record.content_type.in?(%w(image/png application/pdf image/jpeg))
      errors.add(:document, 'Must be an image or a pdf file')
      proof.purge
    end
  end
end