class Overseers::SiteUpdatePolicy < Overseers::CompanyPolicy
    def create?
        admin?
    end
  
    def add_release_notes?
        admin?
    end
  end