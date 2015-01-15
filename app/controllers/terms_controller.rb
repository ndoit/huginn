require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class TermsController < ApplicationController

  ### when all security actions are on, it asks to sign in for #show
  ### when all are off, #update errors out

  # before_filter CASClient::Frameworks::Rails::Filter
  ### commenting out before_filter seems to fix everything
  
  unless @current_user
    skip_before_action :verify_authenticity_token
  end


  def update
    response = Muninn::Adapter.put( "/terms/#{URI.encode(params[:id])}", session[:cas_user], session[:cas_pgt], params[:termJSON] )
    render status: response.code, json: response.body
  end

  def create

    response = Muninn::Adapter.post( '/terms/', session[:cas_user], session[:cas_pgt], params[:term])
    render status: response.code, json: response.body
  end

  def destroy
    response = Muninn::Adapter.delete( "/terms/id/#{URI.encode(params[:id])}", session[:cas_user], session[:cas_pgt] )
    render status: response.code, json: response.body
  end




  def authenticated_show
    if session[:cas_pgt] == nil
      Rails.logger.info("PGT is nil.")
    end

    Rails.logger.info("CAS User: #{session[:cas_user].to_s}, CAS Pgt: #{session[:cas_pgt].to_s}")
    muninn_response = Muninn::Adapter.get( "/terms/" + URI::encode(params[:id]), session[:cas_user], session[:cas_pgt] )
    @term = JSON.parse(muninn_response.body)
    logger.debug("These are the show terms: #{@term}")
    @term["huginn_user"] = session[:cas_user].to_s
    @term["reports"] ||= []

    # GET STAKEHOLDERS FOR TERM
    @stakeholder_hash = {}
    @stakeholder_hash["Responsible"] = []
    @stakeholder_hash["Accountable"] = []
    @stakeholder_hash["Consult"] = []
    @stakeholder_hash["Inform"] = []


    stake_json = @term["stakeholders"]
    if stake_json != nil
     stake_json.each do |stake|
          @stakeholder_hash[stake["stake"]] ||= []
        @stakeholder_hash[stake["stake"]] << {id: stake["id"], text: stake["name"]}
      end
    end
  end



 
  def show

      # GET OFFICES
    office_resp = Muninn::Adapter.get( "/offices", session[:cas_user], session[:cas_pgt] )
    office_json = JSON.parse( office_resp.body )["results"]
    logger.debug("These are the show offices: #{office_json}")
    offices = []
    office_json.each do |office|
      offices << {id: office["data"]["name"], text: office["data"]["name"]}
    end
    @office_json = offices.to_json

      # GET TERM
    muninn_response = Muninn::Adapter.get( "/terms/" + URI::encode(params[:id]), session[:cas_user], session[:cas_pgt] )
    @term = JSON.parse(muninn_response.body)
    @term["reports"] ||= []

      # GET STAKEHOLDERS FOR TERM
    @stakeholder_hash = {}
    @stakeholder_hash["Responsible"] = []
    @stakeholder_hash["Accountable"] = []
    @stakeholder_hash["Consult"] = []
    @stakeholder_hash["Inform"] = []


    stake_json = @term["stakeholders"]
    if stake_json != nil
     stake_json.each do |stake|
          @stakeholder_hash[stake["stake"]] ||= []
        @stakeholder_hash[stake["stake"]] << {id: stake["id"], text: stake["name"]}
      end
    end
  end
  
  def search_string(search_s)
    if !search_s.blank?
      json_string = '{"query":{"match": {"_all": {"query": "' + "#{search_s}" +'","operator": "and" }}},"size":"999","sort":[{"name":{"order":"asc"}}]}'
      #2json_string ='{"query":{"multi_match":{"query": "*' + "#{search_s}" +'*","fields":["name^3","definition"],"type":"phrase","zero_terms_query": "none"}},"from":"0","size":"999","highlight": { "pre_tags": ["<FONT style=\"BACKGROUND-COLOR:yellow\">"],"post_tags": ["</FONT>"],"fields" : {"name" :{},"definition" :{}}}}'
      #1json_string = '{"query":{"query_string": {"query": "*' + "#{search_s}" +'*","fields":["name","definition"],"highlight": { "fields": { "name": {}}}}},"sort":[{"name.raw":{"order":"asc"}}],"from":"0","size":"999"}'
    else
      json_string = '{"query":{"match_all":{}},"from":"0","size":"999"}'
    end
      #json_string = '{"query":{"query_string": {"query": "*' + "#{search_s}" +'*","fields":["name","definition"],"highlight": {"fields": {"name": {"fragment_size" : 150,"number_of_fragments": 5}}},,"sort":[{"name.raw":{"order":"asc"}}],"from":"0","size":"999"}'
      muninn_response_render(json_string)
  end






  def index

  logger.debug("Querying Muninn...")
  
   page =params[:page]
   if params.has_key?(:tags)
    search_s = params[:tags][:search1]

    json_string = Muninn::CustomSearchAdapter.create_search_string(search_s)
    @results  = Muninn::CustomSearchAdapter.custom_query(json_string, params[:page], 15, session[:cas_user], session[:cas_pgt] )

   else
    json_string = '{"query":{"match_all":{}}, "facets": {"tags":{ "terms" : {"field" : "_type"}}},"from":"0","size":"999"}'
    @results = Muninn::CustomSearchAdapter.custom_query(json_string, params[:page], 15, session[:cas_user], session[:cas_pgt] )

   end
    @results_count = @results.select { |k| "#{k[:type]}" =="count"}
    @results_hash = {}
    @results_count.each do |hash|
       @results_hash[hash["term"]] = hash["count"]
    end
    @results = @results.select { |k| "#{k[:type]}" =="term"}
    @results = @results.sort_by { |k| "#{k[:sort_name]}"}
    @results = @results.paginate(:page=> page, :per_page => 15)
     
  end

  def partial_search
    page =params[:page]
    json_string = Muninn::CustomSearchAdapter.create_search_string( params[:q], session[:cas_user], session[:cas_pgt] )
    @results  = Muninn::CustomSearchAdapter.custom_query(json_string, params[:page], 15, session[:cas_user], session[:cas_pgt] )
    @results_count = @results.select { |k| "#{k[:type]}" =="count"}
    @results_count = @results_count[0][:totalcount]
    @results_hash = {}
    @results_count.each do |hash|
       @results_hash[hash["term"]] = hash["count"]
    end

    @results = @results.select { |k| "#{k[:type]}" =="term"}
    @results = @results.sort_by { |k| "#{k[:sort_name]}"}
    @results =@results.paginate(:page=> page, :per_page => 15)
    respond_to do |format|
      format.json {render :json => @results, layout: false}
      format.html {render partial: "partial_search", layout: false }
    end
  end


end
