require "net/http"
require "json"
require "open-uri"

class TermsController < ApplicationController
  #before_filter :authenticate!

  def authenticate!
    CASClient::Frameworks::Rails::Filter.client.proxy_callback_url =
      "https://localhost:4000/cas_proxy_callback/receive_pgt"
    CASClient::Frameworks::Rails::Filter.filter(self)

    if session[:cas_pgt]
      logger.debug ":cas_pgt: " + session[:cas_pgt].to_s
    end
  end

  def show
    muninn_host = "https://bidata-db1-test.dc.nd.edu"
    muninn_port = 443
    
    logger.debug("Querying Muninn...")
  	uri_string = "/terms/" + URI::encode(params[:id])
  	#service_uri = "localhost:3000" + uri_string
  	#logger.debug "*** SESSION KEYS ***: " + session.keys.to_s
  	#proxy_granting_ticket = session[:cas_pgt]
  	#logger.debug "*** PROXY GRANTING TICKET ***: " + proxy_granting_ticket
    #ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(service_uri, proxy_granting_ticket).ticket
  	#logger.debug "*** ACTUAL TICKET ***: " + ticket.to_s
  	muninn_response = Net::HTTP.start(muninn_host, muninn_port) do |http|
  	  http.get(uri_string)
    end
  	@term = JSON.parse(muninn_response.body)
  end
end
