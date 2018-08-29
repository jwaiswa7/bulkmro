class Overseers::InquiryImportPolicy < Overseers::ApplicationPolicy
  def manage_failed_skus?
    record.failed_skus_metadata.any?
  end

  def create_failed_skus?
    manage_failed_skus?
  end
end