require "json"

class CasTestsController < ApplicationController
  unless @current_user
    skip_before_action :verify_authenticity_token
  end

  def index
    if session[:cas_pgt] == nil
      Rails.logger.debug("PGT is nil.")
    end

    Rails.logger.debug("CAS User: #{session[:cas_user].to_s}, CAS Pgt: #{session[:cas_pgt].to_s}")
    muninn_response = Muninn::Adapter.cas_test( session[:cas_user], session[:cas_pgt] )
    @output = JSON.parse(muninn_response.body)
    Rails.logger.debug("Output: #{@output}")

    @cas_pgt = session[:cas_pgt].to_s
    @cas_user = session[:cas_user].to_s
  end
end
