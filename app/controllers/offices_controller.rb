require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class OfficesController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => :authenticated_show
  skip_before_action :verify_authenticity_token

  # display all offices
  def index
    logger.debug("Querying Muninn...")
    offices_resp = MuninnAdapter.get("/offices" )
    offices_sort = JSON.parse(offices_resp.body) ["results"]
    @offices = offices_sort.sort_by{|k| "#{k["data"]["name"]}"}
   
  end

  # display office detail page
  def show
    logger.debug("Querying Muninn...")
    office_resp = MuninnAdapter.get( "/offices/" + URI::encode(params[:id]) )
    @office = JSON.parse(office_resp.body) 
    #@office  =office_sort.sort_by{|hash| "#{hash["stakes"]["name"]}"}

 end

  def update
    response = MuninnAdapter.put( "/offices/#{URI.encode(params[:id])}", params[:officeJSON] )
    render status: response.code, json: response.body
  end

  def create
    response = MuninnAdapter.post( '/offices/', params[:office])
    render status: response.code, json: response.body
  end


  def destroy
    response = MuninnAdapter.delete( "/offices/id/#{URI.encode(params[:id])}" )
    render status: response.code, json: response.body
  end

    
 
end