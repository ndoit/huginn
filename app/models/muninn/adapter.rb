class Muninn::Adapter

  def self.post( resource_uri, body )
    req = Net::HTTP::Post.new( resource_uri )
    req["Content-Type"] = "application/json"
    req.body = body

    Muninn::Adapter.perform( req )

  end

  def self.delete( resource_uri )
    req = Net::HTTP::Delete.new( resource_uri )
    req.body = nil
    Muninn::Adapter.perform( req )
  end

  def self.put( resource_uri, body )
    req = Net::HTTP::Put.new( resource_uri )
    req["Content-Type"] = "application/json"
    req.body = body
    Muninn::Adapter.perform( req )
  end



  def self.get( resource_uri,cas_user = nil,cas_pgt = nil)

    http = Muninn::Adapter.new_http_request

    muninn_host = ENV["muninn_host"]
    muninn_port = ENV["muninn_port"]

    http.use_ssl = ENV["muninn_uses_ssl"]

    ### impersonate cas proxy params ###
    ### uncomment to impersonate ###
    # if cas_user != nil && cas_pgt != nil
    #   cas_service_uri = "https://" + muninn_host.to_s + "/"
    #   proxy_granting_ticket = cas_pgt
    #   ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(
    #     proxy_granting_ticket, cas_service_uri
    #   )
    #   cas_proxy_params = "?service=#{URI::encode(ticket.service)}&ticket=#{ticket.ticket}"
    # elsif cas_user != nil
    #   cas_proxy_params = "?impersonate=#{cas_user}"
    # else
    #   cas_proxy_params = ""
    # end
    ###    ###

    ### regular cas proxy ticket ###
    if cas_user != nil && cas_pgt != nil
      cas_service_uri = "https://" + muninn_host.to_s + "/"
      proxy_granting_ticket = cas_pgt
      ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(
        proxy_granting_ticket, cas_service_uri
      )
      cas_proxy_params = "?service=#{URI::encode(ticket.service)}&ticket=#{ticket.ticket}"
    else
      cas_proxy_params = ""
    end
    ###    ###
    cas_proxy_params = ""
    if !ENV["validate_muninn_certificate"]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE #for when Muninn is using a self-signed cert
    end
     Rails.logger.info("cas_proxy_params ********************* : #{cas_proxy_params}" );
    if ENV["muninn_uses_ssl"]
     muninn_response = HTTParty.get(
      "https://#{muninn_host}:#{muninn_port}/#{resource_uri}#{cas_proxy_params}"
      )
    else
      muninn_response = http.get("http://#{muninn_host}:#{muninn_port}/#{resource_uri}#{cas_proxy_params}")
    end

    muninn_response
  end

  #def self.get( resource_uri,nil,nil )
    #return self.get(resource_uri, nil, nil)
  #end
  private
  def self.new_http_request
    Net::HTTP.new( ENV["muninn_host"], ENV["muninn_port"] )
  end

  def self.perform( req )
    response = Muninn::Adapter.new_http_request.start do |http|
      http.request(req)
    end
  end


end
