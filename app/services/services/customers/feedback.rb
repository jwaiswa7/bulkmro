class Services::Customers::Feedback
  def initialize(company_id)
    @company_id = company_id
  end

  def call
    company = Company.find(@company_id)

    company.contacts.each do |contact|
      puts "send feedback request email to contact #{contact.email}}"
    end
    {success: true, message: 'Feedback request sent successfully'}
  end

  private 
   
  attr_accessor :company
end
