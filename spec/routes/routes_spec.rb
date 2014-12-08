require 'rails_helper'

RSpec.describe "routing to home", :type => :routing do
  it "routes / to welcome#index" do
    expect(:get => "/").to route_to(
      :controller => "welcome",
      :action => "index"
    )
  end
end

RSpec.describe "dataset routing", :type => :routing do
  describe "GET SHOW" do
    it "goes to the show method from 'datasets/:id" do
      expect(:get => "/datasets/1").to route_to(
      :controller => "datasets",
      :action => "show",
      :id => "1"
      )
    end
  end
end
