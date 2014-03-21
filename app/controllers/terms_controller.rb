require "net/http"
require "json"
require "open-uri"

class TermsController < ApplicationController
  before_filter :authenticate!, :only => :authenticated_show

  def authenticate!
    if session[:cas_pgt]
      logger.debug ":cas_pgt: " + session[:cas_pgt].to_s
    end
    if session[:cas_user]
      logger.debug ":cas_user: " + session[:cas_user].to_s
    end
    CASClient::Frameworks::Rails::Filter.client.proxy_callback_url =
      "https://data-test.cc.nd.edu:8443/cas_proxy_callback/receive_pgt"
    CASClient::Frameworks::Rails::Filter.filter(self)
    if session[:cas_pgt]
      logger.debug ":cas_pgt: " + session[:cas_pgt].to_s
    end
  end

  def authenticated_show
    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]
    
    logger.debug("Querying Muninn...")
    uri_string = "/terms/" + URI::encode(params[:id])

    #service_uri = muninn_host + uri_string
    #logger.debug "*** SESSION KEYS ***: " + session.keys.to_s
    #proxy_granting_ticket = session[:cas_pgt]
    #logger.debug "*** PROXY GRANTING TICKET ***: " + proxy_granting_ticket
    #ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(service_uri, proxy_granting_ticket).ticket
    #logger.debug "*** ACTUAL TICKET ***: " + ticket.to_s
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
    @cas_user = session[:cas_user]
  end

  def show
    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]
    
    logger.debug("Querying Muninn...")
  	uri_string = "/terms/" + URI::encode(params[:id])
  	#service_uri = "localhost:3000" + uri_string
  	#logger.debug "*** SESSION KEYS ***: " + session.keys.to_s
  	#proxy_granting_ticket = session[:cas_pgt]
  	#logger.debug "*** PROXY GRANTING TICKET ***: " + proxy_granting_ticket
    #ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(service_uri, proxy_granting_ticket).ticket
  	#logger.debug "*** ACTUAL TICKET ***: " + ticket.to_s
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
end
