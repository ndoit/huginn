class MuninnAdapter




  def self.post( resource_uri, body )
    req = Net::HTTP::Post.new( resource_uri )
    req["Content-Type"] = "application/json"
    req.body = body

    MuninnAdapter.perform( req )

  end

  def self.delete( resource_uri )
    req = Net::HTTP::Delete.new( resource_uri )
    req.body = nil
    MuninnAdapter.perform( req )
  end

  def self.put( resource_uri, body )
    req = Net::HTTP::Put.new( resource_uri )
    req["Content-Type"] = "application/json"
    req.body = body
    MuninnAdapter.perform( req )
  end


  def self.get( resource_uri )

    http = MuninnAdapter.new_http_request

    http.use_ssl = Huginn::Application::CONFIG["muninn_uses_ssl"]

    if !Huginn::Application::CONFIG["validate_muninn_certificate"]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE #for when Muninn is using a self-signed cert
    end

    if Huginn::Application::CONFIG["muninn_uses_ssl"]
      muninn_response = http.get("https://#{muninn_host}:#{muninn_port}/#{resource_uri}")
    else
      muninn_response = http.get("http://#{muninn_host}:#{muninn_port}/#{resource_uri}")
    end

    JSON.parse(muninn_response.body)
  end

  private
  def self.new_http_request
    Net::HTTP.new( Huginn::Application::CONFIG["muninn_host"], Huginn::Application::CONFIG["muninn_port"] )
  end

  def self.perform( req )
    response = MuninnAdapter.new_http_request.start do |http|
      http.request(req)
    end
  end


end
