require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class TermsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => :authenticated_show
  skip_before_action :verify_authenticity_token


  def update

    req = Net::HTTP::Put.new( "/terms/#{URI.encode(params[:id])}" )
    req["Content-Type"] = "application/json"
    req.body = params[:termJSON]

    host = Huginn::Application::CONFIG["muninn_host"]
    port = Huginn::Application::CONFIG["muninn_port"]
    response = Net::HTTP.new( host, port ).start do |http|
      http.request(req)
    end

    render status: response.code, json: response.body
    #render status: 200, text: ""
  end

def create

    req = Net::HTTP::Post.new( "/terms/" )
    req["Content-Type"] = "application/json"
    req.body = params[:term]
    #LogTime.info("Parameters :  params = #{params.to_s}");

    host = Huginn::Application::CONFIG["muninn_host"]
    port = Huginn::Application::CONFIG["muninn_port"]
    response = Net::HTTP.new( host, port ).start do |http|
      http.request(req)
    end

    render status: response.code, json: response.body
    #render status: 200, text: ""
  end

def destroy

    req = Net::HTTP::Delete.new( "/terms/id/#{URI.encode(params[:id])}" )
    req.body = nil
    host = Huginn::Application::CONFIG["muninn_host"]
    port = Huginn::Application::CONFIG["muninn_port"]
    response = Net::HTTP.new( host, port ).start do |http|
      http.request(req)
    end

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
    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]

    logger.debug("Querying Muninn...")
                uri_string = "/terms/" + URI::encode(params[:id])


    http = Net::HTTP.new(muninn_host, muninn_port)
    http.use_ssl = Huginn::Application::CONFIG["muninn_uses_ssl"]
    if !Huginn::Application::CONFIG["validate_muninn_certificate"]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE #for when Muninn is using a self-signed cert
    end
    if Huginn::Application::CONFIG["muninn_uses_ssl"]
                  muninn_response = http.get("https://#{muninn_host}:#{muninn_port}/#{uri_string}")
    else
      muninn_response = http.get("http://#{muninn_host}:#{muninn_port}/#{uri_string}")
    end
    @term = JSON.parse(muninn_response.body)
  end

  def index


    logger.debug("Querying Muninn...")

   if params.has_key?(:tags)
    search_s = params[:tags][:search1]
    search_string(search_s)

      # json_string = '{"query":{"query_string": {"query": "*' + "#{search_param}" +'*","fields":["name","definition"]}},"sort":[{"name":{"order":"asc"}}],"from":"0","size":"999"}'
   else
    json_string = '{"query":{"match_all":{}},"from":"0","size":"999"}'
    @results = MuninnAdapter.custom_query(json_string, params[:page], 20 )

   end

  end


  def search_string(search_s)
    if !search_s.blank?
       json_string =json_string ='{"query":{"match": {"_all": {"query": "' + "#{search_s}" + '" , "operator": "and"}}},"filter":{"type":{"value":"term"}},"from":"0","size":"999"}'
     else
       json_string = '{"query":{"match_all":{}},"from":"0","size":"999"}'
    end

    @results = MuninnAdapter.custom_query(json_string, params[:page], 20 )
  end

  def partial_search
    @results = search_string( params[:q] )
      respond_to do |format|
      format.json {render :json => @results, layout: false}
      format.html {render layout: false }
    end
        #render :text => "hello", :layout => false
  end


end
