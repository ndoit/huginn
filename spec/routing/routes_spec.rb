require 'rails_helper'

RSpec.describe "routing to home", :type => :routing do
  it "routes / to welcome#index" do
    expect(:get => "/").to route_to(
      :controller => "welcome",
      :action => "index"
      # :username => "jsmith"
    )
  end

  # it "does not expose a list of profiles" do
  #   expect(:get => "/profiles").not_to be_routable
  # end
end