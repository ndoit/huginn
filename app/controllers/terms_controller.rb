require "net/http"
require "json"
require "open-uri"

class TermsController < ApplicationController
  before_filter :authenticate!, :only => :authenticated_show

  def session_barf
    session.keys.each do |key|
      logger.debug "Session key #{key.to_s} => #{session[key].to_s}"
    end
  end

  def object_barf(object)
    object.methods.each do |method|
      logger.debug method.to_s
    end
  end

  def authenticate!
    logger.debug "Authenticating..."
    CASClient::Frameworks::Rails::Filter.client.proxy_callback_url =
      "https://data-test.cc.nd.edu/cas_proxy_callback/receive_pgt"
    CASClient::Frameworks::Rails::Filter.filter(self)
    logger.debug "Authentication complete."
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

  def authenticated_show
    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]

    logger.debug "Session at start of authenticated_show method:"
    session_barf

    cas_service_uri = "http://" + muninn_host.to_s
    proxy_granting_ticket = session[:cas_pgt]

    ticket_output = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(proxy_granting_ticket, cas_service_uri)

    logger.debug ticket_output.to_s
    object_barf ticket_output

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
