require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class TermsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => :authenticated_show
  skip_before_action :verify_authenticity_token

  def update
    response = MuninnAdapter.put( "/terms/#{URI.encode(params[:id])}", params[:termJSON] )
    render status: response.code, json: response.body
  end

  def create
    response = MuninnAdapter.post( '/terms/', params[:term])
    render status: response.code, json: response.body
  end

  def destroy
    response = MuninnAdapter.delete( "/terms/id/#{URI.encode(params[:id])}" )
    render status: response.code, json: response.body
  end




  def authenticated_show

    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]

    cas_service_uri = "https://" + muninn_host.to_s + "/"
    proxy_granting_ticket = session[:cas_pgt]
    ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(
      proxy_granting_ticket, cas_service_uri
    )

    logger.debug("Querying Muninn...")
    uri_string = "/terms/" + URI::encode(params[:id])

    muninn_response = HTTParty.get(
      "http://#{muninn_host}:#{muninn_port}/#{uri_string}?service=#{URI::encode(ticket.service)}&ticket=#{ticket.ticket}"
      )

    @term = JSON.parse(muninn_response.body)
    @term["huginn_user"] = session[:cas_user].to_s

  end

  def show


    # GET OFFICES
    office_resp = MuninnAdapter.get( "/offices" )
    office_json = JSON.parse( office_resp.body )["results"]

    offices = []
    office_json.each do |office|
        offices << {id: office["data"]["name"], text: office["data"]["name"]}
    end
    @office_json = offices.to_json



    # GET TERM
    muninn_response = MuninnAdapter.get( "/terms/" + URI::encode(params[:id]) )
    @term = JSON.parse(muninn_response.body)



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


  def index

  logger.debug("Querying Muninn...")

   if params.has_key?(:tags)
    search_s = params[:tags][:search1]

    json_string = MuninnCustomSearchAdapter.create_search_string(search_s)
    @results = MuninnCustomSearchAdapter.custom_query(json_string, params[:page], 20 )

   else
    json_string = '{"query":{"match_all":{}},"from":"0","size":"999"}'
    @results = MuninnCustomSearchAdapter.custom_query(json_string, params[:page], 20 )

   end

  end



  def partial_search
    json_string = MuninnCustomSearchAdapter.create_search_string( params[:q] )
    @results = MuninnCustomSearchAdapter.custom_query(json_string, params[:page], 20 )
      respond_to do |format|
      format.json {render :json => @results, layout: false}
      format.html {render partial: "partial_search", layout: false }
    end
  end


end
