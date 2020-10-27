class Services::Shared::Chewy::RefreshIndices < Services::Shared::BaseService
  def initialize
    begin
      service = Services::Shared::Chewy::RemoveOutdatedIndices.new
      service.delete_outdated_indices
    rescue StandardError => e
      puts "Error----------#{e}----------------------"
    end
  end
end
