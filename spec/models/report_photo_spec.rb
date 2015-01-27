require 'rails_helper'
require 'carrierwave/test/matchers'

describe ReportPhoto do
  include CarrierWave::Test::Matchers

  before(:all) do
    @base_photo = ReportPhoto.new(1)
    @saved_photo = @base_photo.dup
    @saved_photo.report_image = File.open('app/assets/images/thug_dog.jpg')
    @saved_photo.save

    @url = URI(@saved_photo.image_url(:thumb)) 
  end

  after(:all) do
    @saved_photo.report_image.remove!
  end


  context 'Base ReportPhoto' do
    it 'should be of class ReportPhoto' do
      expect(@base_photo).to be_instance_of(ReportPhoto)
    end
  end

  context 'Saved ReportPhoto' do
    it 'saved an image on S3' do
      response = Net::HTTP.get_response(@url)
      expect(response.code).to eql('200')
    end
    it 'removes a saved image on S3' do
      @saved_photo.report_image.remove!
      response = Net::HTTP.get_response(@url)
      expect(response.code).to eql('403')
    end
  end  


  context 'The GET image_url' do
    # it 'should create a filename when given a size'
    it 'should include the matching upload path' do
      expect(@saved_photo.image_url(:small)).to include(@saved_photo.report_image.store_dir)
    end
  end
  

  context 'image resizing' do
  
    it "should scale down a landscape image to be exactly 75 by 75 pixels", :focus => true do 
      @test_photo = ReportPhoto.new(1)
      @test_photo.report_image.store!(File.open('app/assets/images/old_lhamascarf.jpg'))
      expect(@test_photo.report_image.medium).to have_dimensions(75, 75)
    end
    xit "should scale down a landscape image to fit within 200 by 200 pixels" do
      expect(@saved_photo.small).to be_no_larger_than(200, 200)
    end
  end



end