require 'rails_helper'
require 'carrierwave/test/matchers'

xdescribe ReportPhoto do
  include CarrierWave::Test::Matchers

  before do
    # ReportPhoto.enable_processing = true
    @uploader = ReportPhoto.new(1)
    @uploader.save
  end

  after do
    # ReportPhoto.enable_processing = false
    @uploader.remove!
  end

  context 'The image_rul' do
    it 'should create a filename when given a size'
      @uploader
  end
  

  context 'the thumb version' do
    it "should scale down a landscape image to be exactly 75 by 75 pixels" do
      @uploader.image_url(:medium).should have_dimensions(75, 75)
    end
  end

  context 'the small version' do
    it "should scale down a landscape image to fit within 200 by 200 pixels" do
      @uploader.small.should be_no_larger_than(200, 200)
    end
  end

  it "should make the image readable only to the owner and not executable" do
    @uploader.should have_permissions(0600)
  end
end