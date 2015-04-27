require 'rails_helper'
require 'carrierwave/test/matchers'

describe PhotoMapper do
  include CarrierWave::Test::Matchers

  # before(:all) do
  #   # @saved_photo = build(:photo_mapper)
  #   # puts @photo.image_uploader.small.read
    
    # @saved_photo = PhotoMapper.new(1)
    # @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
    # @saved_photo.save


    # @url = URI(@saved_photo.image_url(:thumb))
  # end

  # after(:all) do
  #   @saved_photo.uploader.remove!
  # end


  context 'Base PhotoMapper' do
    it 'should be of class PhotoMapper' do
      @saved_photo = PhotoMapper.new("Super cool Report")
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      @url = URI(@saved_photo.image_url(:thumb))
      expect(@saved_photo).to be_instance_of(PhotoMapper)

    end
  end

  context 'Saved PhotoMapper' do

    it 'saved an image on S3' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      @url = URI(@saved_photo.image_url(:thumb))
      response = Net::HTTP.get_response(@url)
      expect(response.code).to eql('200')
    end
    it 'removes a saved image on S3' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      @url = URI(@saved_photo.image_url(:thumb))

      @saved_photo.uploader.remove!

      response = Net::HTTP.get_response(@url)
      expect(response.code).to eql('403')
    end
  end



  context 'The GET image_url' do
    it 'should include the matching upload path' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      expect(@saved_photo.image_url(:small)).to include(@saved_photo.uploader.store_dir)
    end
    it 'should have the modified time in the filename' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      current_time = Time.now.to_i
      expect(@saved_photo.filename(:small)).to include(current_time.to_s)
    end
    it 'should explicitly match this line with a name as a string' do
      @saved_photo = PhotoMapper.new("Cool Report")
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      current_time = Time.now.to_i
      expect(@saved_photo.image_url(:thumb)).to match("https://s3.amazonaws.com/bi-portal.dcnd/uploads/#{Rails.env}/photo_mapper/Cool%20Report/thumb_#{current_time}_Cool%20Report.png")
    end
    it 'should explicitly match this line with a name as an integer' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      current_time = Time.now.to_i
      expect(@saved_photo.image_url(:thumb)).to match("https://s3.amazonaws.com/bi-portal.dcnd/uploads/#{Rails.env}/photo_mapper/1/thumb_#{current_time}_1.png")
    end
  end
  

  context 'image resizing' do
  
    xit "should scale down a landscape image to be exactly 75 by 75 pixels" do 
      # @test_photo = PhotoMapper.new(1)
      # @test_photo.uploader.store!(File.open('app/assets/images/old_lhamascarf.jpg'))
      expect(@saved_photo.image_url(:thumb)).to have_dimensions(75, 75)
    end
    xit "should scale down a landscape image to fit within 200 by 200 pixels" do
      string = @saved_photo.uploader.small.read.path
      string.slice! "/vagrant/apps/huginn"
      CarrierWave::Test::Matchers::ImageLoader.load_image(string)
      expect(@photo.uploader.small.read).to be_no_larger_than(200, 200)
    end
  end



end