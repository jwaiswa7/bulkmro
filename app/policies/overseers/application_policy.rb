class Overseers::ApplicationPolicy
  attr_reader :overseer, :record

  def initialize(overseer, record)
    @overseer = overseer
    @record = record
  end

  def all_roles?
    admin_or_manager? || cataloging? || sales? || others? || logistics? || hr?
  end

  def admin_or_manager?
    admin? || manager?
  end

  def not_sales?
    admin_or_manager? || cataloging? || logistics?
  end

  def not_logistics?
    !logistics?
  end

  def admin_or_cataloging?
    admin? || cataloging?
  end

  def manager_or_cataloging?
    admin_or_manager? || cataloging?
  end

  def manager_or_sales?
    admin_or_manager? || sales?
  end

  def developer?
    ['bhargav.trivedi@bulkmro.com', 'saurabh.bhosale@bulkmro.com', 'ashwin.goyal@bulkmro.com', 'malav.desai@bulkmro.com', 'prikesh.savla@bulkmro.com', 'amit.goyal@bulkmro.com', 'sandesh.raut@bulkmro.com', 'sourabh.raje@bulkmro.com', 'lopesh.durugkar@bulkmro.com', 'ruta.kambli@bulkmro.com', 'rucha.parab@bulkmro.com', 'meenakshi.naik@bulkmro.com', 'pradeep.ketkale@bulkmro.com'].include? overseer.email
  end

  def admin?
    overseer.admin?
  end

  def manager?
    overseer.manager?
  end

  def sales?
    overseer.inside? || overseer.outside?
  end

  def others?
    overseer.others?
  end

  def cataloging?
    overseer.cataloging?
  end

  def logistics?
    overseer.logistics?
  end

  def hr?
    overseer.hr?
  end

  def accounts?
    overseer.accounts?
  end

  def index?
    all_roles? && !hr?
  end

  def autocomplete?
    index?
  end

  def show?
    index?
  end

  def new?
    index?
  end

  def create?
    new?
  end

  def edit?
    create?
  end

  def update?
    edit?
  end

  def destroy?
    manager?
  end

  def dev?
    Rails.env.development?
  end

  def scope
    Pundit.policy_scope!(overseer, record.class)
  end

  def allow_export?
    developer? || ['vijay.manjrekar@bulkmro.com', 'nilesh.desai@bulkmro.com', 'lavanya.j@bulkmro.com'].include?(overseer.email)
  end

  def allow_logistics_format_export?
    developer? || ['amit.rawool@bulkmro.com'].include?(overseer.email)
  end

  def allow_customer_portal?
    ['kartik.pai@bulkmro.com'].include?(overseer.email)
  end

  def allow_activity_export?
    developer? || ['nilesh.desai@bulkmro.com'].include?(overseer.email)
  end

  def export_rows?
    false
  end

  def is_active?
    record.is_active?
  end

  def export_for_logistics?
    false
  end

  class Scope
    attr_reader :overseer, :scope

    def initialize(overseer, scope)
      @overseer = overseer
      @scope = scope
    end

    def resolve
      if overseer.manager?
        scope.all
      else
        scope.where(created_by: overseer.self_and_descendants)
      end
    end
  end
end
