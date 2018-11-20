class Overseers::PurchaseOrderCommentPolicy < Overseers::ApplicationPolicy
  def new_comment?
    true
  end
end