require 'spec_helper'
require 'rails_helper'
# require 'capybara'
describe 'User Logging In'do

  it "will first visit my app's root page" do 
    visit('/')
    expect(page).to have_content("Welcome To The BI Portal")
    expect(page).to have_content("Log In")
  end

  it "clicks login button taking them to CAS", :js => true do
    visit('/')
    click_on('Log In')
    save_screenshot('../test/tmp/cache/assets/test/file.png')
    expect(page).to have_content("Central Authentication Service (CAS)")
  end

  it "Hopefully will login and CAS accepts a machine running these scripts", :js => true do
    visit('/')
    click_on('Log In')
    fill_in('username', :with => ENV["netid"])
    expect(find_field('username').value).to eq "rsnodgra"
    fill_in('password', :with => ENV["netid_password"])
    expect(find_field('password').value.length).to eq 9
    click_on('LOGIN')
    save_screenshot('../test/tmp/cache/assets/test/file.png')
    expect(page).to have_content("Data Driven Decision Making")
  end
  # it 'quits the driver' do
  #   session.driver.quit
  # end
end