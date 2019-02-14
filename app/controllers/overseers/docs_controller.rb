

class Overseers::DocsController < Overseers::BaseController
  prepend_view_path('app/views/overseers/docs')

  def index
    authorize :doc
    render params[:page], layout: false
  end
end
