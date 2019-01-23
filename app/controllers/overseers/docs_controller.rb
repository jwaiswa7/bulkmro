class Overseers::DocsController < Overseers::BaseController
  def index
    authorize :doc
    render params[:page], layout: false
  end
end