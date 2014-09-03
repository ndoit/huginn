# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Huginn::Application.initialize!


CASClient::Frameworks::Rails::Filter.configure(
:cas_base_url => "https://login-test.cc.nd.edu/cas/",
:proxy_callback_url => "https://bitdata1-dev.dc.nd.edu/cas_proxy_callback/receive_pgt"
)