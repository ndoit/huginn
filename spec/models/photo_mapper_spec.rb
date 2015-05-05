require 'rails_helper'
require 'carrierwave/test/matchers'

describe PhotoMapper do
  include CarrierWave::Test::Matchers

  before(:all) do
    @saved_photo = build(:photo_mapper)
    # puts @photo.image_uploader.small.read
    
    # @saved_photo = PhotoMapper.new(1)
    # @saved_photo.uploader = File.open('app/assets/images/thug_dog.jpg')
    # @saved_photo.save

    @url = URI(@saved_photo.image_url(:thumb))
  end

  after(:all) do
    @saved_photo.uploader.remove!
  end


  context 'Base PhotoMapper' do
    it 'should be of class PhotoMapper' do
      expect(@saved_photo).to be_instance_of(PhotoMapper)

    end
  end

  context 'Saved PhotoMapper' do

    it 'saved an image on S3' do
      response = Net::HTTP.get_response(@url)
      expect(response.code).to eql('200')
    end
    it 'removes a saved image on S3' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog.jpg')
      @saved_photo.save
      @url = URI(@saved_photo.image_url(:thumb))

      @saved_photo.uploader.remove!

      response = Net::HTTP.get_response(@url)
      expect(response.code).to eql('403')
    end
  end



  context 'The GET image_url' do
    # it 'should create a filename when given a size'
    it 'should include the matching upload path' do
      expect(@saved_photo.image_url(:small)).to include(@saved_photo.uploader.store_dir)
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