

class Resources::PaymentTermsType < Resources::ApplicationResource
  def self.identifier
    :GroupNumber
  end

  def self.to_remote(record)
    {
        CreditLimit: "",
        GeneralDiscount: "",
        LoadLimit: "",
        PaymentTermsGroupName: record.name
    }
  end
end
