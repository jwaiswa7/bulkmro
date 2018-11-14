class Services::Shared::Chewy::RefreshIndices < Services::Shared::BaseService
  def initialize
    @indices = Chewy.create_indices
    @indices.each do |index|
      next if index.to_s.include? "::"
      index.reset!
    end
  end
end