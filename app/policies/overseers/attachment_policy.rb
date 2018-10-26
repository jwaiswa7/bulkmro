class Overseers::AttachmentPolicy < Overseers::ApplicationPolicy
  def destroy?
    true
  end
end