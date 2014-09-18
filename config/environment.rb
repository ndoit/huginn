# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Huginn::Application.initialize!


CASClient::Frameworks::Rails::Filter.configure(
:cas_base_url => Huginn::Application.config.cas_base_url,
:proxy_callback_url => Huginn::Application.config.cas_proxy_callback_url
)