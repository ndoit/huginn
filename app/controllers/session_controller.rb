class SessionController < ApplicationController

    before_filter CASClient::Frameworks::Rails::Filter, :only => :login


    # Upon login, takes you to report gallery
    def login
      redirect_to "/browse/reports"
    end


    # NEEDS TO BE IN SESSION CONTROLLER
    def logout
      session.clear
      CASClient::Frameworks::Rails::Filter.logout(self)
    end


end
