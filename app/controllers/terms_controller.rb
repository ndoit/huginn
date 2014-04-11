require "net/http"
require "json"
require "open-uri"
require "httparty"

class TermsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => :authenticated_show

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
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
      #{}"http://#{muninn_host}:#{muninn_port}/#{uri_string}"
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

    def index
    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]
    
    logger.debug("Querying Muninn...")
   # test_string = "{ "query" : {"match_all": {}}, "from":0, "size":999}"
    uri_string = "/search/custom/query"
    #service_uri = "localhost:3000" + uri_string
    #logger.debug "*** SESSION KEYS ***: " + session.keys.to_s
    #proxy_granting_ticket = session[:cas_pgt]
    #logger.debug "*** PROXY GRANTING TICKET ***: " + proxy_granting_ticket
    #ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(service_uri, proxy_granting_ticket).ticket
    #logger.debug "*** ACTUAL TICKET ***: " + ticket.to_s
   
    #http = Net::HTTP.new(muninn_host, muninn_port)
    #http.use_ssl = Huginn::Application::CONFIG["muninn_uses_ssl"]
    #if !Huginn::Application::CONFIG["validate_muninn_certificate"]
      #http.verify_mode = OpenSSL::SSL::VERIFY_NONE #for when Muninn is using a self-signed cert
   # end
    json_string = '{"query":{"match_all":{}},"from":"0","size":"999"}'
    actual_json = JSON.parse(json_string)
    muninn_response = HTTParty.get("http://#{muninn_host}:#{muninn_port}/search/custom/query", { :body => json_string, 
    :headers => { 'Content-Type' => 'application/json'} })
   
     
    # muninn_response = http.get("https://#{muninn_host}:#{muninn_port}/#{uri_string}")
    # @output = muninn_response.body.to_json
    output_string= ActiveSupport::JSON.decode(muninn_response.body.to_json)
    @results = extract_results(output_string)
    # render "index.html.erb"
    #@results =  muninn_response.body 
    #respond_to do |format|
    #format.json { render :json => JSON.parse(@results) }
    #format.html { render "index.html.erb" }
   #end

  end
   def extract_results(search_response)
    response_hash = JSON.parse(search_response)
    if !response_hash.has_key?("result")
     LogTime.info("No contents.")
      return []
    end
    output = []
    response_hash["result"]["hits"]["hits"].each do |hit|
      node = {
        :id => hit["_id"].to_i,
        :type => hit["_type"],
        :score => hit["_score"],
        :data => hit["_source"]

      }
      output << node
    end
    return output
  end


end
