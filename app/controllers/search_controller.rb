#require 'rails/config'

class SearchController < ApplicationController

  def show
    logger.debug("Querying Muninn...")

    muninn_response = Muninn::CustomSearchAdapter.typeahead(params[:search_for], session[:cas_user], session[:cas_pgt])
    @results = muninn_response
  end
end
