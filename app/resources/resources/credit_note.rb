class Resources::CreditNote < Resources::ApplicationResource
  def self.identifier
    :DocNum
  end

  def self.create_from_sap
    response = get("/#{collection_name}")
    validated_response = get_validated_response(response)
    validated_response['value'].each do |sap_credit_memo|
      metadata = self.build_metadata(sap_credit_memo)
      service = Services::Callbacks::CreditNotes::Create.new(metadata, nil)
      service.call
      next
    end
  end

  def self.build_metadata(remote_response)
    {
      'controller' => 'callbacks/credit_notes',
      'memo_number' => remote_response['DocNum'],
      'memo_date' => remote_response['DocDate'].to_date,
      'memo_amount' => remote_response['DocTotal'],
      'invoice_number' => remote_response['Reference1']
    }
  end
end
