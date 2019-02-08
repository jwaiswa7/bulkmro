# frozen_string_literal: true

class Resources::BusinessPartnerGroup < Resources::ApplicationResource
  def self.identifier
    :Code
  end

  def self.to_remote(record)
    name = record.name[0..19]

    if record.is_customer?
      {
          Name: name,
          Type: "bbpgt_CustomerGroup"
      }
    elsif record.is_supplier?
      {
          Name: name,
          Type: "bbpgt_VendorGroup"
      }
    end
  end
end
