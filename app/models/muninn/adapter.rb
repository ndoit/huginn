class Muninn::Adapter
  def self.cas_proxy_params(cas_user, cas_pgt)
    Rails.logger.info("cas_user = #{cas_user.to_s}, cas_pgt = #{cas_pgt.to_s}")

    if cas_user != nil && cas_pgt != nil
      cas_service_uri = "https://" + muninn_host.to_s + "/"
      proxy_granting_ticket = cas_pgt
      ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(
        proxy_granting_ticket, cas_service_uri
      )
      return "?service=#{URI::encode(ticket.service)}&ticket=#{ticket.ticket}"
    elsif cas_user != nil
      return "?impersonate=#{cas_user}"
    else
      return ""
    end
  end


  def self.post( resource_uri, cas_user, cas_pgt, body )
    Rails.logger.debug(
      "Muninn POST: resource_uri = #{resource_uri}, cas_user = #{cas_user.to_s}, cas_pgt = #{cas_pgt.to_s}, body = #{body.to_s}"
      )
    req = Net::HTTP::Post.new( resource_uri + cas_proxy_params(cas_user, cas_pgt) )
    req["Content-Type"] = "application/json"
    req.body = body

    output = Muninn::Adapter.perform( req )
    Rails.logger.debug("Muninn POST output: #{output}")
    return output
  end

  def self.delete( resource_uri, cas_user, cas_pgt, body = nil )
    Rails.logger.debug(
      "Muninn DELETE: resource_uri = #{resource_uri}, cas_user = #{cas_user.to_s}, cas_pgt = #{cas_pgt.to_s}, body = #{body.to_s}"
      )
    req = Net::HTTP::Delete.new( resource_uri + cas_proxy_params(cas_user, cas_pgt) )
    req.body = body

    output = Muninn::Adapter.perform( req )
    Rails.logger.debug("Muninn DELETE output: #{output}")
    return output
  end

  def self.put( resource_uri, cas_user, cas_pgt, body )
    Rails.logger.debug(
      "Muninn PUT: resource_uri = #{resource_uri}, cas_user = #{cas_user.to_s}, cas_pgt = #{cas_pgt.to_s}, body = #{body.to_s}"
      )
    req = Net::HTTP::Put.new( resource_uri + cas_proxy_params(cas_user, cas_pgt) )
    req["Content-Type"] = "application/json"
    req.body = body

    output = Muninn::Adapter.perform( req )
    Rails.logger.debug("Muninn PUT output: #{output}")
    return output
  end

  def self.get( resource_uri, cas_user, cas_pgt, body = nil )
    Rails.logger.debug(
      "Muninn GET: resource_uri = #{resource_uri}, cas_user = #{cas_user.to_s}, cas_pgt = #{cas_pgt.to_s}, body = #{body.to_s}"
      )
    response = HTTParty.get("http://" + ENV["muninn_host"] + ":" + ENV["muninn_port"] + resource_uri + cas_proxy_params(cas_user,cas_pgt),
      :body => (body == nil) ? nil : body,
      :headers => {'Content-Type' => 'application/json'} )

    Rails.logger.debug("Muninn GET output: #{response}")
    return response
  end

  private

  def self.new_http_request
    return Net::HTTP.new( ENV["muninn_host"], ENV["muninn_port"] )
  end

  def self.perform( req )
    response = Muninn::Adapter.new_http_request.start do |http|
      http.request( req )
    end
    return response
  end

end
