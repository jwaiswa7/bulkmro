class Overseers::Companies::ContactsController < Overseers::Companies::BaseController
  def autocomplete
    @contacts = ApplyParams.to(@company.contacts, params)
    authorize @contacts
  end
end
