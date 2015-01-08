require 'rails_helper'

RSpec.describe DatasetsController, :type => :controller do
  context "GET #show/:id" do
    it 'gets a response back from muninn' do
      get :show, id: "Lhamascarf"
      expect(@dataset).to have_http_status(200)
    end
  end
end