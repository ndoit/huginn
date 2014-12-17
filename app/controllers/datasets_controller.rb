class DatasetsController < ApplicationController
  def show
    logger.debug("Querying Muninn...")
    datasets_resp = Muninn::Adapter.get( "/datasets/" + URI::encode(params[:id]) )
    @dataset = JSON.parse(datasets_resp.body)
  end
end