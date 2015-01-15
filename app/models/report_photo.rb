# for now, this class only exists to contain the CarrierWave uploader


class ReportPhoto 

  extend CarrierWave::Mount
  attr_accessor :id, :report_image
  mount_uploader :report_image, ReportImageUploader

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
