class Resources::Bank < Resources::ApplicationResource
  def self.identifier
    :AbsoluteEntry
  end

  def self.to_remote(record)
    record.reload

    params = {
        BankCode: record.code,
        BankName: record.name,
        SwiftNo: record.swift_number,
        CountryCode: record.country_code
    }

    params
  end
end
