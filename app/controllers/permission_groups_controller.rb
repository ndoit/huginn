require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class PermissionGroupsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => :authenticated_show
  skip_before_action :verify_authenticity_token

  # display all permission groups
  def index

    logger.debug("Querying Muninn...")
    page =params[:page]
    json_string = Muninn::CustomSearchAdapter.create_search_string( params[:q], session[:cas_user], session[:cas_pgt] )
    @results= Muninn::CustomSearchAdapter.custom_query(json_string, params[:page], 15, session[:cas_user], session[:cas_pgt] )
    @results_= @results.select { |k| "#{k[:type]}" =="permission_group"}
    @results = @results.sort_by { |k| "#{k[:sort_name]}"}
    @results =@results.paginate(:page=> page, :per_page => 15)


  end
  # display permission_group detail page
  def show
    logger.debug("Querying Muninn...")
    permission_group_resp = Muninn::Adapter.get( "/permission_groups/" + URI::encode(params[:id]), session[:cas_user], session[:cas_pgt] )
    @permission_group = JSON.parse(permission_group_resp.body)

  end

  def update
    logger.debug("/permission_groups/id/#{URI.encode(params[:id])}")
    response = Muninn::Adapter.put( "/permission_groups/id/#{URI.encode(params[:id])}", session[:cas_user], session[:cas_pgt], params[:permissiongroupJSON] )
    render status: response.code, json: response.body
  end

  def create
    response = Muninn::Adapter.post( '/permission_groups/', session[:cas_user], session[:cas_pgt], params[:permission_group])
    render status: response.code, json: response.body
  end


  def destroy
    response = Muninn::Adapter.delete( "/permission_groups/id/#{URI.encode(params[:id])}", session[:cas_user], session[:cas_pgt] )
    render status: response.code, json: response.body
  end

 def partial_search
    page =params[:page]
    json_string = Muninn::CustomSearchAdapter.create_search_string( params[:q] )
    @results= Muninn::CustomSearchAdapter.custom_query(json_string, params[:page], 15, session[:cas_user], session[:cas_pgt] )
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
