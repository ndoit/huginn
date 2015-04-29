# for now, this class only exists to contain the CarrierWave uploader

class PhotoMapper
  extend CarrierWave::Mount
  attr_accessor :name, :uploader
  mount_uploader :uploader, ImageUploader

  ## 2.0.0-p353 :003 > r.report_image = File.open('app/assets/images/thug_dog.jpg')
  ##   => #<File:app/assets/images/thug_dog.jpg>

  def initialize( name )
    @name = name
  end

  def save
      self.store_uploader!
  end

  def image_url
    # xxxx/report_photo/xxxx is where the problem for getting was
    # by having 'model.class.to_s' the file path is dependent on the model
    # when GETting the images, they wont forever be a 'report'
    # so might want to refactor this in the future
    url = "/uploads/#{Rails.env}/photo_mapper/#{URI.escape(self.name.to_s)}/#{filename}"
    root + url
  end

  def filename
    URI.escape(self.name.to_s) + ".png"
  end

  def root
    "#{ENV['S3_ASSET_URL']}/#{ENV['S3_BUCKET_NAME']}"
  end

end
