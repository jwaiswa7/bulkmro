class Overseers::ContactsController < Overseers::BaseController

  def autocomplete
    @contacts = ApplyParams.to(Contact.all, params)
    authorize @contacts
  end

end