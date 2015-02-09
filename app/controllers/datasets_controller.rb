class DatasetsController < ApplicationController
  def show
    logger.debug("Querying Muninn...")

    dataset_resp = Muninn::Adapter.get( "/datasets/" + URI::encode(params[:id]), session[:cas_user], session[:cas_pgt] )
    @dataset = JSON.parse(dataset_resp.body)

  end
end