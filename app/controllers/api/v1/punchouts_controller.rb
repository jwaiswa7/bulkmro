class Api::V1::PunchoutsController < Api::V1::BaseController
  before_action :log_api_request
  
  def auth
    # puts "content-type -> #{request.headers["Content-Type"]}"
    # puts "Host -> #{request.headers["Host"]}"
    # puts "User-Agent -> #{request.headers["User-Agent"]}"
    # puts "Accept -> #{request.headers["Accept"]}"
    # puts "Accept-Encoding -> #{request.headers["Accept-Encoding"]}"
    # puts "Connection -> #{request.headers["Connection"]}"
    # puts "Cookie -> #{request.headers["Cookie"]}"
    puts request.headers.env.reject { |key| key.to_s.include?('.') }
    # puts request.headers.each { |key, value|  }
    # debugger
    # service = Services::Api::Cxml.new(request, @api_request)
    # response_data = service.parser

    # if response_data
    #   respond_to do |format|
    #     format.xml { render :xml => response_data }
    #   end
    # end
  end

  def route
       
  end

  private

  def log_api_request
    @api_request = ApiRequest.create(
      endpoint: request.url,
      created_at: Time.now.iso8601
    )
  end
  
end
  