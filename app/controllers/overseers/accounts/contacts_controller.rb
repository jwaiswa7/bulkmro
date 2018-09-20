class Overseers::Companies::ContactsController < Overseers::Companies::BaseController

  def index
    @contacts = @account.contacts
    authorize @contacts
  end

end
