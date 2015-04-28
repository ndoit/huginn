class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  skip_before_action :verify_authenticity_token

  def show
    roles_resp = Muninn::Adapter.get( "/security_roles", session[:cas_user], session[:cas_pgt])
    roles_json = JSON.parse(  roles_resp.body )["results"]
    roles= []
    roles_json.each do |role|
      roles << {id: role["data"]["id"], text: role["data"]["name"]}
    end

    @security_roles_json = roles.to_json

    
      
    unless current_user.security_roles == nil
      @user_roles = []
      current_user.security_roles.each do |role|
        @user_roles << {id: role["id"], text: role["name"]}
      end
      @user_roles_json = @user_roles.to_json
    end
  end

end
