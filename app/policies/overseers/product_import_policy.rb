class Overseers::ProductImportPolicy < Overseers::ApplicationPolicy
    def new?
      cataloging? || admin? || super_admin? 
    end

    def create?
        new?
    end
end