class Overseers::ContactsController < Overseers::BaseController

  def index
    @contacts = ApplyDatatableParams.to(Contact.all.includes(:companies), params)
    authorize @contacts
  end

  def autocomplete
    @contacts = ApplyParams.to(Contact.all, params)
    authorize @contacts
  end

end