

class Overseers::TaxCodePolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging?
  end
  def autocomplete_for_product?
    autocomplete?
  end
end
