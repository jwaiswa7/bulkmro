class Overseers::TaxCodePolicy < Overseers::ApplicationPolicy
  def autocomplete?
    true
  end
end