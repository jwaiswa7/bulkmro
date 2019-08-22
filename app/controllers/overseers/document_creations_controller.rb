class Overseers::DocumentCreationsController < Overseers::BaseController
  def new
    authorize_acl :document_creation
  end

  def create
    authorize_acl :document_creation
    class_name = doc_creation_params['option'].gsub(' ', '')
    @object = class_name.constantize.by_number(doc_creation_params['document_number'])
    session[:number] = doc_creation_params['document_number']
    session[:option] = doc_creation_params['option']
    if @object.present?
      notice = "#{doc_creation_params['option']} already exists"
    else
      ['Resources', class_name].join('::').constantize.set_multiple_items([doc_creation_params['document_number'].to_i])
      notice = "#{doc_creation_params['option']} created"
    end
    redirect_back(fallback_location: new_overseers_document_creation_path, notice: notice)
  end

  private

    def doc_creation_params
      params.require(:document_creation).permit(
        :option,
        :document_number
      )
    end
end
