class Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner < Services::Shared::BaseService
  def initialize(purchase_order)
    @purchase_order = purchase_order
    @company_name = purchase_order.inquiry.company.name
    @companies_group_1 = ["Cummins Technologies India Pvt. Ltd.", "Cummins India Ltd.", "Cummins Generator Technologies India Pvt. Ltd.",
                          "Beckman Coulter India Pvt. Ltd.", "Huntsman International India Pvt Ltd", "Godrej and Boyce Manufacturing Co. Ltd.",
                          "DHL Supply Chain India Pvt. Ltd."]
    @companies_group_2 = ["Cargill India Pvt. Ltd.", "Piramal Enterprises Ltd.", "ABB India Ltd."]
    @companies_group_3 = ["Covestro India Pvt. Ltd.", "Shell", "GlaxoSmithKline Consumer Healthcare Ltd.", "Eaton"]
    @companies_group_4 = ["Graziano Trasmissioni India Pvt. Ltd.", "Applied Materials India Pvt. Ltd.", "Henkel Adhesive Technologies India Pvt. Ltd."]
    @companies_group_5 = ["KBS Diamond", "Reliance Corporate IT Park Ltd.", "Reliance Industries Ltd.", "ZF India Pvt. Ltd.",
                          "GE India Industrial Pvt. Ltd. (Division: Wind Energy) (Wind India BID code 285005)", "GE India Industrial Pvt. Ltd.",
                          "GE Power Conversion India Pvt. Ltd." "GE Diesel Locomotive Pvt. Ltd."]
  end

  def call
    case
    when companies_group_1.include?(company_name) then
      Overseer.logistics.where(email: "farhan.ansari@bulkmro.com").first
    when companies_group_2.include?(company_name) then
      Overseer.logistics.where(email: "mahendra.kolekar@bulkmro.com").first
    when companies_group_3.include?(company_name) then
      Overseer.logistics.where(email: "sumit.sharma@bulkmro.com").first
    when companies_group_4.include?(company_name) then
      Overseer.logistics.where(email: "tushar.jadhav@bulkmro.com").first
    when companies_group_5.include?(company_name) then
      Overseer.logistics.where(email: "vignesh.gounder@bulkmro.com").first
    else
      Overseer.logistics.where(email: "amit.rawool@bulkmro.com").first
    end
  end

  private
  attr_accessor :purchase_order, :company_name, :companies_group_1, :companies_group_2, :companies_group_3, :companies_group_4, :companies_group_5
end