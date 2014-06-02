class OfficesController < ApplicationController

  def index
    logger.debug("Querying Muninn...")
    @offices = MuninnAdapter.get( "/offices/" )
    render json: @offices
  end

  def show
    logger.debug("Querying Muninn...")
    @office = MuninnAdapter.get( "/offices/" + URI::encode(params[:id]) )
  end
end
