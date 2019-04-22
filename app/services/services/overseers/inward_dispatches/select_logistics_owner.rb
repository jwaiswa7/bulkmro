class Services::Overseers::InwardDispatches::SelectLogisticsOwner < Services::Shared::BaseService
  def initialize(purchase_order, company_name: nil)
    @purchase_order = purchase_order
    @company_name = company_name || purchase_order.inquiry.company.name
    @companies_group_1 = ['Cummins Technologies India Pvt. Ltd.', 'Cummins India Ltd.', 'Cummins Generator Technologies India Pvt. Ltd.', 'Beckman Coulter India Pvt. Ltd.', 'Huntsman International India Pvt Ltd',
                          'Godrej and Boyce Manufacturing Co. Ltd.', 'Oerlikon Balzers Coating India Pvt. Ltd.', 'DHL Supply Chain India Pvt. Ltd.', 'ZF India Pvt. Ltd.', 'Survival Systems India']

    @companies_group_2 = ['Cargill India Pvt. Ltd.', 'Piramal Enterprises Ltd.', 'ABB India Ltd.', 'Colgate-Palmolive India Ltd.']

    @companies_group_3 = ['Graziano Trasmissioni India Pvt. Ltd.', 'Applied Materials India Pvt. Ltd.', 'Henkel Adhesive Technologies India Pvt. Ltd.', 'Procter & Gamble Home Products Pvt. Ltd.',
                          'Procter & Gamble Hygiene and Health care Ltd (C)', 'Procter & Gamble Hygiene and Health care Ltd. (S)', 'Gillete India Ltd. (C)', 'Gillete India Pvt Ltd']

    @companies_group_4 = ['Covestro India Pvt. Ltd.', 'Shell', 'GlaxoSmithKline Consumer Healthcare Ltd.', 'Eaton India Innovation Center LLP', 'KBS Diamond', 'Reliance Corporate IT Park Ltd.',
                          'Reliance Industries Ltd.', 'GE India Industrial Pvt. Ltd. (Division: Wind Energy) (Wind India BID code 285005)', 'GE India Industrial Pvt. Ltd.', 'GE Power Conversion India Pvt. Ltd.',
                          'Flextronics Technologies India Pvt. Ltd.', 'Ashirvad Pipes Pvt. Ltd.', 'Bennett Coleman and Co. Ltd.', 'Reckitt Benckiser (India) Pvt. Ltd.',
                          'Jones Lang Lasalle Property Consultants India Pvt. Ltd.', 'Indo Mim Pvt. Ltd.', 'GE Diesel Locomotive Pvt. Ltd.']

    @companies_group_5 = ['GHCL', 'L & T-MHPS Turbine Generators Pvt. Ltd.	', 'Alstom Bharat Forge Power Pvt. Ltd.', 'GE Power India Ltd.', 'GE Power Systems India Pvt. Ltd.',
                          'GE T and D India Ltd.', 'Inarco Pvt. Ltd.', 'Ingersoll Rand (India) Ltd.']


  end

  def call
    case
    when companies_group_1.include?(company_name) then
      Overseer.logistics.where(email: 'farhan.ansari@bulkmro.com').first
    when companies_group_2.include?(company_name) then
      Overseer.logistics.where(email: 'mahendra.kolekar@bulkmro.com').first
    when companies_group_3.include?(company_name) then
      Overseer.logistics.where(email: 'tushar.jadhav@bulkmro.com').first
    when companies_group_4.include?(company_name) then
      Overseer.logistics.where(email: 'vignesh.gounder@bulkmro.com').first
    when companies_group_5.include?(company_name) then
      Overseer.logistics.where(email: 'ajay.rathod@bulkmro.com').first
    else
      nil
    end
  end

  private
    attr_accessor :purchase_order, :company_name, :companies_group_1, :companies_group_2, :companies_group_3, :companies_group_4, :companies_group_5
end
