class Services::Overseers::InwardDispatches::SelectLogisticsOwner < Services::Shared::BaseService
  def initialize(purchase_order, company_name: nil)
    @purchase_order = purchase_order
    @company_name = company_name || purchase_order.inquiry.company.name
    @companies_group_1 = ['Beckman Coulter India Pvt. Ltd.', 'CORE LOG C', 'Cummins Fuel Systems India', 'Cummins Generator Technologies India Pvt. Ltd.', 'Cummins India Ltd.',
                          'Cummins Technologies India Pvt. Ltd.', 'Daulatram Engg. Services Pvt. Ltd.', 'DHL Supply Chain India Pvt. Ltd.', 'Godrej and Boyce Manufacturing Co. Ltd.',
                          'Hindustan Zinc Ltd.', 'Huntsman International India Pvt Ltd', 'IAC International Automotive India Pvt. Ltd.', 'Merck Life Science Private Limited',
                          'MERINO INDUSTRIES LIMITED', 'Metal Blaz (M) Sdn Bhd', 'Metalman Auto Private Limited', 'Oerlikon Balzers Coating India Pvt. Ltd.', 'PAR ASSOCIATES.',
                          'Survival Systems India', 'ZF India Pvt. Ltd.']

    @companies_group_2 = ['ABB India Ltd.', 'Cargill India Pvt. Ltd.', 'Colgate-Palmolive India Ltd.', 'Gillette India Ltd.', 'HPCL Mittal Energy Ltd.', 'Piramal Enterprises Ltd.',
                          'Procter & Gamble Home Products Pvt. Ltd.', 'Procter & Gamble Hygiene and Health Care Ltd', 'Schlumberger Asia Services Ltd.']

    @companies_group_3 = ['Abbott Healthcare Pvt. Ltd.', 'Applied Materials India Pvt. Ltd.', 'Cars24 Services Pvt. Ltd.', 'GIA India Laboratory Pvt. Ltd.',
                          'Graziano Trasmissioni India Pvt. Ltd.', 'Henkel Adhesive Technologies India Pvt. Ltd.', 'Henkel Anand India Pvt. Ltd.', 'Henkel Laundry & Home Care',
                          'Myntra Jabong India Pvt. Ltd.', 'Olx India Pvt Ltd', 'Reckitt Benckiser (India) Pvt. Ltd.', 'Sulzer Pumps India Pvt. Ltd.']

    @companies_group_4 = ['Aegis Logistic Limited', 'Ashirvad Pipes Pvt. Ltd.', 'Bennett Coleman and Co. Ltd.', 'Covestro India Pvt. Ltd.', 'Eaton India Innovation Center LLP', 'Eureka Forbes Limited',
                          'Flextronics Technologies India Pvt. Ltd.', 'GE Diesel Locomotive Pvt. Ltd.', 'GE Global Sourcing India Pvt Ltd', 'GE India Industrial Pvt. Ltd.',
                          'GE India Industrial Pvt. Ltd. (Division: Wind Energy) (Wind India BID code 285005)', 'GE Power Conversion India Pvt. Ltd.', 'GE Power Systems India Pvt. Ltd.', 'GlaxoSmithKline Consumer Healthcare Ltd.',
                          'Indo Mim Pvt. Ltd.', 'Jones Lang Lasalle Property Consultants India Pvt. Ltd.', 'Konkan Barge Builders Pvt. Ltd.', 'Petrofac Engineering India Pvt Ltd', 'Raymond Ltd.',
                          'Reliance Corporate IT Park Ltd.', 'Reliance Industries Ltd.', 'SONNIVA ENERGY MAKİNA INŞAAT İTH. İHR. LTD. ŞTİ.', 'Supermax personal Care Pvt. Ltd.', 'Tata Steel BSL Ltd.',
                          'The Times of India', 'The Times of India Group']

    @companies_group_5 = ['Alstom Bharat Forge Power Pvt. Ltd.', 'Bharat Earth Movers Limited', 'Bombardier Transportation India Pvt. Ltd.', 'Cg Power and Industrial Solutions Ltd.', 'Essar Steel India Limited',
                          'GAIL India Limited', 'Genesis Luxury Fashion Private Limited', 'GE Power India Ltd.', 'GE T and D India Ltd.', 'GHCL Ltd.', 'Inarco Pvt. Ltd.', 'Ingersoll Rand (India) Ltd.',
                          'Max Wangle', 'Prestige Group Of Industries', 'Summit Electric Supply', 'Technip India Ltd.', 'Trusted Industry', 'Universal Enterprises', 'UPL Limited']

    @companies_group_6 = ['Accuramech Industrial Engineering Pvt. Ltd.', 'Air India Engineering Services Limited', 'Amazon Seller Services Pvt. Ltd.', 'Asian Hotels (West) Ltd.', 'Asian Institute of Medical Sciences',
                          'ATC Tires Pvt. Ltd.', 'Bharati Chemicals', 'Citrus processing India Pvt. Ltd.', 'Clarke Energy India Pvt. Ltd.', 'Cocretec Systems', 'COEO Labs Pvt. Ltd.', 'Crossways Vertical Solutions Pvt. Ltd.',
                          'Deepak Electric Corporation', 'Dyna Filters Pvt. Ltd.', 'ESK India Commerce & Trade Pvt. Ltd.', 'GL and V India Pvt. Ltd.', 'GOL Offshore Ltd.', 'India Nippon Electrical Ltd.', 'INS Hansa, Indian Navy',
                          'Jasubhai Engineering Pvt. Ltd.', 'J.B. Chemicals and Pharmaceuticals Ltd.', 'Kich Industries', 'Lakeway Industries INC', 'Lear Corporation', 'Luxury Products Trendsetter Pvt. Ltd.',
                          'Macpower CNC Machines Pvt. Ltd.', 'Mott MacDonald Pvt. Ltd.', 'National Fertilizer Ltd.', 'Nayara Energy Ltd.', 'Nitrotech Engineering Services', 'OMRON HEALTHCARE INDIA PRIVATE LIMITED', 'P2 Power Solutions',
                          'Projects and Development India Ltd.', 'Ramky Enviro Engineers Ltd', 'Rashtriya Chemicals and Fertilizers Ltd.', 'Safe-Tronocs Automation Pvt. Ltd.', 'Sai Machine Tools Pvt. Ltd.', 'Shop Mate',
                          'Slidewell Meilleur Tech-Pvt. Ltd.', 'SpiceJet Ltd.', 'Sri Lakshmi Enterprises', 'Tehmetall-2002', 'Veermata Jijabai Technological Institute', 'Vigel Manufacturing Technologies Pvt. Ltd.']
  end

  def call
    case
    when companies_group_1.include?(company_name) then
      Overseer.logistics.where(email: 'farhan.ansari@bulkmro.com').first
    when companies_group_2.include?(company_name) then
      Overseer.logistics.where(email: 'mahendra.kolekar@bulkmro.com').first
    when companies_group_3.include?(company_name) then
      Overseer.logistics.where(email: 'pooja.poojary@bulkmro.com').first
    when companies_group_4.include?(company_name) then
      Overseer.logistics.where(email: 'vignesh.gounder@bulkmro.com').first
    when companies_group_5.include?(company_name) then
      Overseer.logistics.where(email: 'ajay.rathod@bulkmro.com').first
    when companies_group_6.include?(company_name) then
      Overseer.logistics.where(email: 'logistics@bulkmro.com').first
    else
      nil
    end
  end

  private
    attr_accessor :purchase_order, :company_name, :companies_group_1, :companies_group_2, :companies_group_3, :companies_group_4, :companies_group_5, :companies_group_6
end
