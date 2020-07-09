class Api::V1::PunchoutsController < Api::V1::BaseController
  
  def auth
    service = Services::Api::Cxml.new(request)
    response_data = service.parser

    respond_to do |format|
      format.xml { render :xml => response_data }
    end
  end
  
end
  