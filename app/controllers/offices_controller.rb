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
   # offices_resp = MuninnAdapter.get("/offices" )
    #offices_sort = JSON.parse(offices_resp.body) ["results"]
   # @results_office = offices_sort.sort_by{|k| "#{k["data"]["name"]}"}
    page =params[:page]
    json_string = MuninnCustomSearchAdapter.create_search_string( params[:q] )
    @results= MuninnCustomSearchAdapter.custom_query(json_string, params[:page], 15 )
    @results_= @results.select { |k| "#{k[:type]}" =="office"}
    @results = @results.sort_by { |k| "#{k[:sort_name]}"}
    @results =@results.paginate(:page=> page, :per_page => 15)
   
       
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

 def partial_search
    page =params[:page]
    json_string = MuninnCustomSearchAdapter.create_search_string( params[:q] )
    @results= MuninnCustomSearchAdapter.custom_query(json_string, params[:page], 15 )
    @results_count = @results.select { |k| "#{k[:type]}" =="count"}
    @results_count = @results_count[0][:totalcount]
    @results_hash = {}
    @results_count.each do |hash|
       @results_hash[hash["term"]] = hash["count"]
    end

    @results = @results.select { |k| "#{k[:type]}" == "office"}
    @results = @results.sort_by { |k| "#{k[:sort_name]}"}
    @results = @results.paginate(:page=> page, :per_page => 15)
      respond_to do |format|
      format.json {render :json => @results, layout: false}
      format.html {render partial: "partial_search", layout: false }
    end
 end

 
end