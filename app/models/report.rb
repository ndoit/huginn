# for now, this class only exists to contain the CarrierWave uploader
class Report

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
    	filename = size.to_s + "_" + self.id.to_s + ".png"

    	root = "https://s3-us-west-2.amazonaws.com/brich-fog-test"
    	url = "/uploads/#{Rails.env}/report/#{self.id.to_s}/#{filename}"
    	root + url
    end


end