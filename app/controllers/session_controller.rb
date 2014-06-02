class SessionController < ActionController::Base


    def logout
      CASClient::Frameworks::Rails::Filter.logout(self)
    end

end
