#require 'rails/config'

class SearchController < ApplicationController

  def show
    muninn_host = "localhost"
    muninn_port = 3000
    
    logger.debug("Querying Muninn...")
  	uri_string = "/search/" + URI::encode(params[:search_for])
  	#service_uri = "localhost:3000" + uri_string
  	#logger.debug "*** SESSION KEYS ***: " + session.keys.to_s
  	#proxy_granting_ticket = session[:cas_pgt]
  	#logger.debug "*** PROXY GRANTING TICKET ***: " + proxy_granting_ticket
    #ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(service_uri, proxy_granting_ticket).ticket
  	#logger.debug "*** ACTUAL TICKET ***: " + ticket.to_s
  	muninn_response = Net::HTTP.start(muninn_host, muninn_port) do |http|
  	  http.get(uri_string)
    end
  	@results = JSON.parse(muninn_response.body)
  end
end
