class FileValidator < ActiveModel::Validator
  def validate(record)
    if options[:attachment].present? && record.send(attachment).attached?
      if record.send(attachment).blob.byte_size > file_size_in_megabytes * 1024 * 1024
        record.send(attachment).purge
        record.errors.add(attachment, "must be less than #{file_size_in_megabytes} mb in size")
      elsif !record.send(attachment).blob.content_type.in? file_content_types
        record.send(attachment).purge
        record.errors.add(attachment, 'must be an image or pdf file')
      end
    end
  end

  def attachment
    options[:attachment].to_s
  end

  def file_size_in_megabytes
    options[:file_size_in_megabytes] || 2
  end

  def file_content_types
    options[:file_content_types] || %w(image/png application/pdf image/jpeg application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/msword)
  end
end
