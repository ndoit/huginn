class SessionController < ApplicationController

    before_filter CASClient::Frameworks::Rails::Filter, :only => :login



    def login
      # render js: "alert('Hello Rails');"
      # logger.debug("This is in the session controller")
      redirect_to "/browse/reports"
      # redirect_to :controller => 'guide', :action => 'index'
    end


    # NEEDS TO BE IN SESSION CONTROLLER
    def logout
      session.clear
      CASClient::Frameworks::Rails::Filter.logout(self)
    end


end
