Fog.mock!
Fog::Mock.reset
connection = Fog::Storage.new(
  :aws_access_key_id => ENV['S3_KEY'],
  :aws_secret_access_key => ENV['S3_SECRET'],
  :provider => 'AWS'
  )
connection.directories.create(:key => ENV['S3_BUCKET_NAME'])