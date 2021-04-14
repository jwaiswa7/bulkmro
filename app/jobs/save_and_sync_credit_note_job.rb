# frozen_string_literal: true

class SaveAndSyncCreditNoteJob < ActiveJob::Base
  queue_as :default

  def perform(next_page_url)
    puts "Job for #{next_page_url} Start"
    Resources::CreditNote.create_from_sap(next_page_url)
    puts "Job for #{next_page_url} End"
  end
end
