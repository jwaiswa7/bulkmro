

class Overseers::Accounts::BaseController < Overseers::BaseController
  before_action :set_account

  private
    def set_account
      @account = Account.find(params[:account_id])
    end
end
