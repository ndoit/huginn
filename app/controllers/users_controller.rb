class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  skip_before_action :verify_authenticity_token

  def show
  end

end
