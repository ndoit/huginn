class SessionController < ActionController::Base

    before_filter CASClient::Frameworks::Rails::Filter, :only => :login

    def login
      redirect_to root_url
    end


    def logout
      session.clear
      CASClient::Frameworks::Rails::Filter.logout(self)
    end

end
