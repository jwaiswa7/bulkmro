# frozen_string_literal: true

require "csv"

class Services::Shared::Spreadsheets::CsvExporter < Services::Shared::BaseService
  def initialize(name, start_at, end_at, fields, records)
    @name = name
    @start_at = start_at
    @end_at = end_at
    @fields = fields
    @records = records

    create_file()
  end

  def create_file
    raise
  end
end
