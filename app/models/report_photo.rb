# for now, this class only exists to contain the CarrierWave uploader


class ReportPhoto 

  extend CarrierWave::Mount
  attr_accessor :id, :report_image
  mount_uploader :report_image, ReportImageUploader
  ## should probably rename :report_image to something that describes its behavior
  ## perhaps something like :accept_image
  ## because in the console to get the image into the ReportPhoto class =>
    ## 2.0.0-p353 :003 > r.report_image = File.open('app/assets/images/thug_dog.jpg')
    ##   => #<File:app/assets/images/thug_dog.jpg>

  def initialize( id )
    @id = id
  end

  def save
      self.store_report_image!
  end

  def image_url( size )  
    # xxxx/report_photo/xxxx is where the problem for getting was
    # by having 'model.class.to_s' the file path is dependent on the model
    # when GETting the images, they wont forever be a 'report'
    # so might want to refactor this in the future
    url = "/uploads/#{Rails.env}/report_photo/#{self.id.to_s}/#{filename(size)}"
    root + url
  end

  def filename(size)
    @filename = size.to_s + "_" + self.id.to_s + ".png"
  end

  def root
    "#{ENV['S3_ASSET_URL']}/#{ENV['S3_BUCKET_NAME']}"
  end

end
