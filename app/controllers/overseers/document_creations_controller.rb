class Overseers::DocumentCreationsController < Overseers::BaseController
  def new
    authorize :document_creation
  end
end
