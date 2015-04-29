# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # by having 'model.class.to_s' the file path is dependent on the model
    # when GETting the images, they wont forever be a 'report'
    "uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{model.name}"
  end
 
  def filename
    "#{model.name}.png" if original_filename
  end 

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [75, 75]
  #   process :convert => 'png'
  # end

  # version :small do
  #   process :resize_to_fit => [150, 150]
  #   process :convert => 'png'
  # end

  # version :medium do
  #   process :resize_to_fit => [350, 350]
  #   process :convert => 'png'
  # end

  # version :large do
  #   process :resize_to_fit => [500, 500]
  #   process :convert => 'png'
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def current_time
    @@current_time ||= calculate_time
  end
  
  private
  
  def calculate_time
    Time.now.to_i
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
    
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
