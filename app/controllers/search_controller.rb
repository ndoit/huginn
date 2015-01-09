#require 'rails/config'

class SearchController < ApplicationController

  def show
    muninn_host = ENV["muninn_host"]
    muninn_port = ENV["muninn_port"]

    logger.debug("Querying Muninn...")
  	uri_string = "/search/" + URI::encode(params[:search_for])

    muninn_response = Muninn::Adapter.get(uri_string, session[:cas_user], session[:cas_pgt])
    @results = JSON.parse(muninn_response.body)
  end
end
