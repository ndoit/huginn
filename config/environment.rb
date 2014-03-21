# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Huginn::Application.initialize!


CASClient::Frameworks::Rails::Filter.configure(
:cas_base_url => "https://login-test.cc.nd.edu/cas/",
#:cas_base_url => "https://localhost:8443/cas-server-webapp-3.5.2",
:proxy_callback_url => "https://data-test.cc.nd.edu/cas_proxy_callback/receive_pgt"
#:logger => cas_logger
)