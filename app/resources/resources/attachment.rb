class Resources::Attachment < Resources::ApplicationResource
  include Net

  def self.collection_name
    'Attachments2'
  end

  def self.identifier
    :AbsoluteEntry
  end

  def self.to_remote(record)
    remote_attachments = []

    Net::SCP.start(SAP.server[:host], SAP.login[:user], :password => SAP.login[:password]) do |scp|
      record.attachments.each do |attachment|
        if attachment.try(:key)
          path = ActiveStorage::Blob.service.send(:path_for, attachment.key)

          if File.exist?(path)

            filename = [record.inquiry_number, attachment.key, attachment.filename.base].join('_')
            extension = attachment.filename.extension_without_delimiter

            remote_attachment = OpenStruct.new(
                :FileExtension => extension,
                :FileName => filename,
                :SourcePath => SAP.attachment_directory,
                :UserID => "1"
            )

            scp.upload!(path, [SAP.attachment_directory, filename].join("/"))

            remote_attachments.push(remote_attachment.marshal_dump)
          end
        end
      end
    end


    {
        Attachments2_Lines: remote_attachments.as_json
    }
  end


  def self.sanitize_filename(name)
    name.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "�").strip.tr("\u{202E}%$|:;/\t\r\n\\", "-")
  end
end


=begin
    {
        "Attachments2_Lines": [
            {
                "FileExtension": "sod",
                "FileName": "mod_negotiation",
                "SourcePath": "usr/sap/SAPBusinessOne/B1_SHF/Sprint",
                "UserID": "1"
            }
        ]
    }
=end

=begin

  Net::SCP.start(SAP.server[:host], SAP.login[:user], :password => SAP.login[:password]) do |scp|
    # upload a file to a remote server

    path = ActiveStorage::Blob.service.send(:path_for,i.customer_po_sheet.key)
    filename = path.split("/").last
    scp.upload!(path, SAP.attachment_directory)


  end

Net::SCP.upload!(SAP.server[:host], SAP.login[:user], ActiveStorage::Blob.service.send(:path_for,i.customer_po_sheet.key), [SAP.attachment_directory,"_POSHEET"], :ssh => { :password => SAP.login[:password] })

=end