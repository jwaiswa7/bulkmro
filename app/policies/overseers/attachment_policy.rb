

class Overseers::AttachmentPolicy < Overseers::ApplicationPolicy
  def destroy?
    all_roles?
  end
end
