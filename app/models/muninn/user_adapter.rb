require "net/http"
require "uri"
class Muninn::UserAdapter

	def self.security_roles( netid )
		uri = URI.parse("http://#{ENV['muninn_host']}:#{ENV['muninn_port']}/users/#{netid}/roles")
	    http = Net::HTTP.new( uri.host, uri.port )
	    response = http.request(Net::HTTP::Get.new( uri.request_uri  ))
	    json = JSON.parse(response.body)
	    json["roles"]
	end

end