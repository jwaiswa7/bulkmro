class Overseers::TaxCodePolicy < Overseers::ManagerApplicationPolicy
  def autocomplete?
    true
  end
end