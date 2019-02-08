# frozen_string_literal: true

class Services::Overseers::InquiryImports::ListImporter < Services::Overseers::InquiryImports::BaseImporter
  def call
    if import.save
      set_rows

      call_base
    end
  end

  def set_rows
    import.import_text.split("\n").each_with_index do |list_item, index|
      tuples = list_item.delete(" ").gsub(/[\r\n]/, "").split(",")

      sku = tuples[0]
      quantity = tuples.length > 1 ? tuples[1] : 1

      rows.push("sku" => sku, "quantity" => quantity, "sr_no" => import.inquiry.last_sr_no + index + 1)
    end
  end
end
