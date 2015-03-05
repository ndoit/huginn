require "net/http"
require "uri"
require "json"
require "open-uri"
require "httparty"

class Muninn::UserAdapter

  def self.security_roles( netid )
    uri = URI.parse("http://localhost:3000/users/#{netid}/roles")
    json = net_http_parse( uri )
    json["roles"]
  end

  def self.get_user_object( netid )
    # uri = URI.parse("http://localhost:3000/users/#{netid}")
    Munnin::Adapter.get( "/users/" + URI::encode( netid ), session[:cas_user], session[:cas_pgt] )
  end

  private

    def self.net_http_parse(uri)
      http = Net::HTTP.new( uri.host, uri.port )
      response = http.request(Net::HTTP::Get.new( uri.request_uri  ))
      json = JSON.parse(response.body)
    end

end