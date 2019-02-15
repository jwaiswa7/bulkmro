require 'rake'

class Services::Shared::Chewy::RefreshIndices < Services::Shared::BaseService
  def initialize
    Rails.application.class.load_tasks
    Rake::Task['chewy:reset'].invoke
  end
end
