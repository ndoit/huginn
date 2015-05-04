require 'rails_helper'
require 'carrierwave/test/matchers'

describe PhotoMapper do
  include CarrierWave::Test::Matchers

  context 'Base PhotoMapper' do
    it 'should be of class PhotoMapper' do
      @saved_photo = PhotoMapper.new("Super cool Report")
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      expect(@saved_photo).to be_instance_of(PhotoMapper)
    end
    it 'when not passed a timestamp, returns current time' do
      @saved_photo = PhotoMapper.new("Super cool Report")
      expect(@saved_photo.timestamp).to eql(Time.now.to_i.to_s)
    end
    it 'when passed a custom timestamp, it sets as that' do
      @saved_photo = PhotoMapper.new("Super cool Report", 123456789)
      expect(@saved_photo.timestamp).to eql("123456789")
    end
    it 'when passed a custom timestamp, image url contains it' do
      @saved_photo = PhotoMapper.new("Super cool Report", 123456789)
      expect(@saved_photo.image_url).to include("123456789")
    end
  end

  context 'PhotoMapper basic function' do
    it 'saved an image on S3' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/old_lhamascarf.jpg')
      @saved_photo.save
      url = URI(@saved_photo.image_url)
      response = Net::HTTP.get_response(url)
      expect(response.code).to eql('200')
    end
    it 'removes a saved image on S3' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      url = URI(@saved_photo.image_url)
      @saved_photo.uploader.remove!
      response = Net::HTTP.get_response(url)
      expect(response.code).to eql('403')
    end
    it 'removes a saved image with custom timestamp on S3' do
      @saved_photo = PhotoMapper.new(1, 123456789)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      url = URI(@saved_photo.image_url)
      @saved_photo.uploader.remove!
      response = Net::HTTP.get_response(url)
      expect(response.code).to eql('403')
    end
    it 'removes a saved image from a different object' do
      @saved_photo = PhotoMapper.new(1, 123456789)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      @saved_photo.save
      @different_photo = PhotoMapper.new(1, 123456789)
      @different_photo.uploader.remove_avatar!
      @different_photo.uploader.save
      url = URI(@different_photo.image_url)
      response = Net::HTTP.get_response(url)
      expect(response.code).to eql('403')
    end
  end

  context 'current_time is same between both files' do
    it 'should have a current_time method return an integer close to seconds' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      expect(@saved_photo.timestamp.to_s.length).to match(10)
    end
    it 'time is in ImageUploader class' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      expect(@saved_photo.uploader.filename).to include(@saved_photo.timestamp.to_s)
    end
    it 'should have the modified time in the full filename' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      current_time = Time.now.to_i
      expect(@saved_photo.filename).to include(@saved_photo.timestamp.to_s)
    end
  end

  context 'The GET image_url' do
    it 'should include the matching upload path' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      expect(@saved_photo.image_url).to include(@saved_photo.uploader.store_dir)
    end
    it 'should explicitly match this line with a name as a string' do
      @saved_photo = PhotoMapper.new("Cool Report")
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      current_time = Time.now.to_i
      expect(@saved_photo.image_url).to match("https://s3.amazonaws.com/bi-portal.dcnd/uploads/#{Rails.env}/photo_mapper/Cool%20Report/Cool%20Report_#{@saved_photo.timestamp}.png")
    end
    it 'should explicitly match this line with a name as an integer' do
      @saved_photo = PhotoMapper.new(1)
      @saved_photo.uploader = File.open('app/assets/images/thug_dog2.jpg')
      current_time = Time.now.to_i
      expect(@saved_photo.image_url).to match("https://s3.amazonaws.com/bi-portal.dcnd/uploads/#{Rails.env}/photo_mapper/1/1_#{@saved_photo.timestamp}.png")
    end
  end

end