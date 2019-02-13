

class MultipleImageFileValidator < ActiveModel::Validator
  def validate(record)
    if options[:attachments].present? && record.send(attachments).attached?
      record.send(attachments).attachments.each do |attachment|
        if attachment.blob.byte_size > file_size_in_megabytes * 1024 * 1024
          attachment.purge
          record.errors.add(attachments, "must be less than #{file_size_in_megabytes} mb in size")
        elsif !attachment.blob.content_type.in? file_content_types
          attachment.purge
          record.errors.add(attachments, "must be an jpg / jpeg / png")
        end
      end
    end
  end

  def attachments
    options[:attachments].to_s
  end

  def file_size_in_megabytes
    options[:file_size_in_megabytes] || 2
  end

  def file_content_types
    options[:file_content_types] || %w(image/jpg image/jpeg image/png)
  end
end
