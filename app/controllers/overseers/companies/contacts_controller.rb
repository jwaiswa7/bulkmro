# frozen_string_literal: true

class Overseers::Companies::ContactsController < Overseers::Companies::BaseController
  def autocomplete
    @contacts = ApplyParams.to(@company.contacts, params)
    authorize_acl @contacts
  end
end
