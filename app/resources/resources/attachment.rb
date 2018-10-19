require 'net/scp'
require 'net/scp'

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

    ssh_private_keys = ['-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA9bBug/z3ZxZnfS4sBNolGjq3+JFWb8odFtq55m7w+zsAe6uC
fPkIJaDdJfqwr6sk3991heT93CbqLf9ZWS6sDLJpQ2d5a/rEO8n2H10WPb1DmT9P
YQC3zotMktGq7ENYL7QBDgXK1VOsV2JRnvSr6i8i9OQjOATp/1YxLdE0wh6/Qym5
S+rU825YZED2GpeHJIVUvFuRjXFPASQQsV7BwM5Msp+FRWFmOlHilDDFpPjSQSOK
lnkkaFBXPMox56OTb/+4Ihkmd+Oawl0ofuxWmlWUrzxevlL2Xa7EJki1WidrcXYI
nqEW/afe/YMWZ/wDWO77QGfwUang+erBJBdfjwIDAQABAoIBAFzVRHz0yZqXGZVw
K8vNjXViuH7gk7N7wBARp2qNgtq6yYzxGkYUZuKo7Mbb+YT2+uDoc2SbSNy1i4jD
0kPjYbkOdL22TGfjgeBBiJEDQFMlv3QZOuohNlKByfYz6QyKybiEoF1nDOQcUKNY
EBUqyAadtuyngzM4kB4duEliojeyXvYlUaTYOTJqlEhKoRPqYxgy/44+qw0Bt4ta
ZeabeaNvRPMD9qnsBRz29Yfv0BIaXOYTZyWlg09pbmFuBEAHRwg6NQHgOuKHX9Hl
v/x2gAdo8NrTPkLHiqc50hDjctHVPjiukxRea/J4OrwCgIkwER+Amozmx/df14BR
KhdfkqkCgYEA+tRvT/kq2Fo0y0LrxPKT4obj1fcatQCFTn0+S4m68/iT1vAowX4w
4XW6CEzZgxIl0/ngTjibl3+h4kFEUfp0OQkN+4EV0xzTTtBOybd1O6iaWB5zwu8c
aSyJYlxSwbn8BVYl6z94NpG6lMoJo+QoGwH04tU+Ks61HbGe16xx040CgYEA+sDe
/Uy8Ds63SQOx07njlbPIwu/SrQ+grxemHc2c1V8E+j+ghfU/pIwQcLqN6sDIUGjG
fBw7oxWve4nKW2HqkDy7U1M/gW9IOL67fd0D1NfbDeGtcIDXvLqAj2c3lzYZ2CgF
PTFTfJQJWvzN+b0/yAxcK+aIkoiCdPB6iDueCosCgYEApH1fqhB62nr9mDaAqx1x
geJ30z9DUmPPCBP2IE9oPMpNGW1RLOL2Z0RvBTZwhhYGnKaHRIS29HkMznWCukgG
o8ieVMroZxPGNy9AG+SlisQcw6DkxXdNKGO+jLSCyOyQq2c9YrKywQZ8V0rPW50p
99wmngK9zBDWkWyEAGfkFZkCgYAtAroEVeXb8pdL7/HXw6JqmN8MvufeUNPTGjej
WekxE+Fc2lcCNMe7zbiVw6b94KUUafpXBOpfl+DsGAvO44Cra3tktajMnyEjrnkR
Wr75UdXsY/oyG66eHgw9sZV0+y0gc+6c0WHfFuOnBYIjtijgy/cvmi4hv4dLXm9g
TPNNiQKBgQCvM1FiwATvx88AltNTeaCD3UzUr9ND2UnARYW+Fy4tJBYb0hUBtqeq
tq7iFj/oZ0WuMVBpik7S47FVc9SeuWTUcbRwC87lF5aobMyUNIaxc06+4zR9Hl5X
ulmwwTdSSRVmjSfz4OxPuSNQdXmYhHDkXMKfewl4mkEJSp92a1HHXw==
-----END RSA PRIVATE KEY-----']

    # Net::SSH.start(:host, username, key_data: ssh_private_keys, keys_only: true) do |ssh|
    #   ssh.scp.upload!(source_file, destination_file)
    # end
    username = 'pradeep'
    #Net::SCP.start(SAP.server[:host], SAP.login[:user], :password => SAP.login[:password]) do |scp|
    #
    Net::SSH.start(SAP.server[:host], username, key_data: ssh_private_keys, keys_only: true) do |ssh|
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

            ssh.scp.upload!(path, [SAP.attachment_directory, filename].join("/"))
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