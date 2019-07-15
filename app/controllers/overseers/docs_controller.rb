class Overseers::DocsController < Overseers::BaseController
  prepend_view_path('app/views/overseers/docs')

  def index
    authorize_acl :doc
    render params[:page], layout: false
  end
end
