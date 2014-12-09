class DatasetsController < ApplicationController
  def show
    logger.debug("Querying Muninn...")
    dataset_resp = Muninn::Adapter.get( "/datasets/" + URI::encode(params[:id]) )
    @dataset = JSON.parse(reports_resp.body)
  end
end