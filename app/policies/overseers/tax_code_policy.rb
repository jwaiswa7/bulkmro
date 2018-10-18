class Overseers::TaxCodePolicy < Overseers::ManagerPolicy
  def autocomplete?
    true
  end
end