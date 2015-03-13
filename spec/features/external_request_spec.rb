require 'spec_helper'
require 'rails_helper'

describe 'some stuff which requires js', :js => true do

  it 'will visit an external webpage' do
    visit("http://example.com")
    expect(page).to have_content("Example Domain")
  end

  it 'will visit a more complicated webpage', :js => true do
    visit("http://foundation.zurb.com/")
    expect(page).to have_content("The most advanced responsive front-end framework in the world.")
  end

  it "will visit my app's root page" do 
    visit('/')
    expect(page).to have_content("Welcome To The BI Portal")
    page.driver.reset!

  end

  it 'will visit a second website with ssl and not raise timeout errors' do
    visit("https://github.com/")
    expect(page).to have_content("2015 GitHub, Inc.")
    page.driver.reset!


    # This worked last time I did it. Was very pleased
    # it's saved in the parent 'apps' folder holding huginn and muninn
    # save_screenshot('../test/tmp/cache/assets/test/file.png')
  end

  it 'will visit a third website with ssl and not raise timeout errors', :js => true do
    visit("https://www.creditkarma.com/")
    expect(page).to have_content("Credit Karma")

    # This worked last time I did it. Was very pleased
    # it's saved in the parent 'apps' folder holding huginn and muninn
    # save_screenshot('../test/tmp/cache/assets/test/file.png')
  end
end