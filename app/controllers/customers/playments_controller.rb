require 'httparty'
class Customers::PlaymentsController < Customers::BaseController
  protect_from_forgery with: :null_session

  def create
    authorize :Playment
    response = HTTParty.post("http://localhost:3000/api/v1/articles", body: {"reference_id":  {"title": "Hello", "content": "loowweerr ddoowwnn", "slug": "hello1"}})
    response.parsed_response
  end

  def index
    response = HTTParty.get("http://localhost:3000/api/v1/articles")
    response.parsed_response
  end
end