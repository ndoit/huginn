require 'rails_helper'
require 'carrierwave/test/matchers'

describe ReportPhoto do
  include CarrierWave::Test::Matchers
  
  let(:base_report_photo) { 
    ReportPhoto.new(1)
  }

  let (:saved_report_photo) {
    temp_base_photo = base_report_photo.dup
    temp_base_photo.report_image = File.open('app/assets/images/thug_dog.jpg')
    temp_base_photo.save
    temp_base_photo
    }

  let (:url) { 
    URI(saved_report_photo.image_url(:thumb))
  }


  context 'Base ReportPhoto' do
    it 'should be of class ReportPhoto' do
      expect(base_report_photo).to be_instance_of(ReportPhoto)
    end
  end

  context 'saved report_photo' do
    it 'saved an image on S3' do
      response = Net::HTTP.get_response(url)
      expect(response.code).to eql('200')
    end
    it 'removes a saved image on S3' do
      saved_report_photo.report_image.remove!
      response = Net::HTTP.get_response(url)
      expect(response.code).to eql('403')
    end
  end  


  context 'The GET image_url' do
    # it 'should create a filename when given a size'
    it 'should include the matching upload path' do
      expect(saved_report_photo.image_url(:small)).to include(saved_report_photo.report_image.store_dir)
    end

  end
  

  context 'image resizing' do
  
    it "should scale down a landscape image to be exactly 75 by 75 pixels" do
      expect(saved_report_photo.image_url(:medium)).to have_dimensions(75, 75)
    end
  
    xit "should scale down a landscape image to fit within 200 by 200 pixels" do
      saved_report_photo.small.should be_no_larger_than(200, 200)
    end
  end

end