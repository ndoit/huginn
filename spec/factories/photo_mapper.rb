FactoryGirl.define do
  factory :photo_mapper do
    id 1
    uploader Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, 'spec/fixtures/myfiles/testing_darth_vader.jpg')))
    
      # For classes that inject initialize parameters on new instances
    initialize_with { new(id) }

      # FactoryGirl by default is built for active record and uses a
      # .save! method. We're rolling a simple .save
      # This prevents an `unknown method .save!` error
    to_create { |instance| instance.save }

  end
end