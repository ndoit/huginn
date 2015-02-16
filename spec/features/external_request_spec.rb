require 'spec_helper'

describe 'External request', :type => :feature do
  
  # before do
  #   Capybara.current_driver = :selenium
  # end

  it 'finds muninn api is running' do
    session = Capybara::Session.new(:webkit)
    session.visit('http://www.google.com')
    # session.visit('http://localhost:3000/')
    # page.has_content?('Ruby on Rails: Welcome aboard')
  end

  xit 'can grab datasets from muninn' do
    uri = URI('http://localhost:3000/datasets')
    response = Net::HTTP.get(uri)
    expect(response).to be_an_instance_of(String)
  end

end