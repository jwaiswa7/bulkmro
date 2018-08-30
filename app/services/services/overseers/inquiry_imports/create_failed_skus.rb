class Services::Overseers::InquiryImports::CreateFailedSkus < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call
    excel_import.rows.each do |row|
      if row.marked_for_destruction?
        row.reload
      end
    end

    excel_import.save
  end

  def notify

  end

  attr_accessor :inquiry, :excel_import
end