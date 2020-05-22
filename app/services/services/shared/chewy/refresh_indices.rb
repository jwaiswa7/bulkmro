require 'rake'

class Services::Shared::Chewy::RefreshIndices < Services::Shared::BaseService
  def initialize
    Rails.application.class.load_tasks
    begin
      service = Services::Shared::Chewy::RemoveOutdatedIndices.new
      service.delete_outdated_indices
    rescue StandardError => e
      puts "Error----------#{e}----------------------"
    end
    Rake::Task['chewy:reset'].invoke
  end
end
