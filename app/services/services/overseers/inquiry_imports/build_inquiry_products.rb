# frozen_string_literal: true

class Services::Overseers::InquiryImports::BuildInquiryProducts < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call
    service = Services::Overseers::InquiryImports::NextSrNo.new(inquiry)

    excel_import.rows.reverse.each do |row|
      if row.failed?

        if Product.find_by_sku(row["sku"]).present?
          row.sku = Services::Resources::Shared::UidGenerator.product_sku(excel_import.rows.map { |r| r["sku"] })
        end

        row.build_inquiry_product(
          inquiry: inquiry,
          import: excel_import,
          sr_no: service.call(row.metadata["sr_no"] || row.metadata["id"]),
          product: Product.new(
            inquiry_import_row: row,
            name: row.metadata["name"],
            sku: row.sku,
            mpn: row.metadata["mpn"],
            brand: Brand.find_by_name(row.metadata["brand"]),
          ),
          quantity: row.metadata["quantity"].to_i
        )
      end
    end
  end

  attr_accessor :inquiry, :excel_import
end
