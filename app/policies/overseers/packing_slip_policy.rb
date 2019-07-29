class Overseers::PackingSlipPolicy < Overseers::ApplicationPolicy
  def submit_packing?
    true
  end

  def edit_outward_packing_slips?
    true
  end
end
