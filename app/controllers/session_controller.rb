class SessionController < ApplicationController

    before_filter CASClient::Frameworks::Rails::Filter, :only => :login



    def login
      redirect_to root_url
    end


    # NEEDS TO BE IN SESSION CONTROLLER
    def logout
      session.clear
      CASClient::Frameworks::Rails::Filter.logout(self)
    end


end
