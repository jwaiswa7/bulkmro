class Customers::RfqPolicy < Customers::ApplicationPolicy
  def index?
    bombardier? || vertiv? || bulkmro?
  end

  def new?
    bombardier? || vertiv? || bulkmro?
  end

  def create?
    bombardier? || vertiv?  || bulkmro?
  end

  def show?
    bombardier? || vertiv?  || bulkmro?
  end

  private

    def bombardier?
      contact.account_id == 2208
    end

    def vertiv?
      contact.account_id == 2478
    end

    def bulkmro?
      contact.account_id == 329
    end
end
