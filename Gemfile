source 'https://rubygems.org'

# image upload
# http://railscasts.com/episodes/374-image-manipulation
# http://railscasts.com/episodes/253-carrierwave-file-uploads
# how to use carrierwave without a table -- 	https://coderwall.com/p/e9d_ja
# ---------------------------------------------------------------------
# Setup
# sudo yum install ImageMagick (case sensitive)
# rails g uploader image_uploader
# https://gist.github.com/cblunt/1303386
gem 'fog', '~> 1.23.0', require: "fog/aws/storage" # for uploading to Amazon S3.  http://railscasts.com/episodes/383-uploading-to-amazon-s3
gem 'mini_magick'
gem 'carrierwave'
# ---------------------------------------------------------------------
#image upload

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

# Use Foundation 5
gem 'foundation-rails' , '~> 5.3.0.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Use haml for beautification and workflow
gem 'haml', '~>4.0.5'

#use this for html tag rendering in json data
#gem 'angularjs-rails-resource', '~> 1.1.0'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'thread_safe' , '~> 0.3.1'

gem 'will_paginate', '~> 3.0.5'

gem 'rubycas-client', '2.3.10.rc1'
gem 'rails-config'
gem 'httparty'

gem "select2-rails"

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0'
  gem 'capybara'
  gem 'factory_girl_rails'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
gem 'unicorn'
gem 'dotenv'
#gem 'puma'
#ND foundation
gem 'nd_foundation'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
