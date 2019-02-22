class Overseers::InquiryImportPolicy < Overseers::ApplicationPolicy
  def manage_failed_skus?
    record.rows.failed.any? && record.excel?
  end

  def create_failed_skus?
    manage_failed_skus?
  end

  def load_alternatives?
    true
  end
end
