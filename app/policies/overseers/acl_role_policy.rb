class Overseers::AclRolePolicy < Overseers::ApplicationPolicy
  def index?
    admin? || hr?
  end

  def edit?
    (admin? || hr?) && record != overseer
  end

  def get_resources?
    true
  end

  def save_acl_resources?
    true
  end

  def edit_acl?
    true
  end

  def get_acl?
    true
  end

  def update_acl?
    true
  end
end
