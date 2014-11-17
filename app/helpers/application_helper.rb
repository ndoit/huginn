module ApplicationHelper

  def self.log( msg )
    logger.debug(msg)
  end

end
