#require 'rails/config'

class SearchController < ApplicationController

  def show
    muninn_host = "bitdata-db1-test.dc.nd.edu"
    muninn_port = 443
    
    logger.debug("Querying Muninn...")
  	uri_string = "/search/" + URI::encode(params[:search_for])
  	#service_uri = "localhost:3000" + uri_string
  	#logger.debug "*** SESSION KEYS ***: " + session.keys.to_s
  	#proxy_granting_ticket = session[:cas_pgt]
  	#logger.debug "*** PROXY GRANTING TICKET ***: " + proxy_granting_ticket
    #ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(service_uri, proxy_granting_ticket).ticket
  	#logger.debug "*** ACTUAL TICKET ***: " + ticket.to_s
    http = Net::HTTP.new(muninn_host, muninn_port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE #we are using a self-signed cert at the moment
    muninn_response = http.get("https://#{muninn_host}:#{muninn_port}/#{uri_string}")
  	@results = JSON.parse(muninn_response.body)
  end
end
