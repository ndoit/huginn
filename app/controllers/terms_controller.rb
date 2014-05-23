require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class TermsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => :authenticated_show
  skip_before_action :verify_authenticity_token


  def update

    path = "/terms/#{URI.encode(params[:id])}"
    req = Net::HTTP::Put.new(path)
    req["Content-Type"] = "application/json"
   # req.set_form_data(params)
    # THIS WORKS
    #req.body = '{"id": 4513,created_date":"2014-05-21T21:07:48Z","modified_date":"2014-05-21T21:07:48Z","id":4513,"definition":"FROM HUGIN An Active Faculty member who holds a current appointment with a Secondary Faculty Appointment Type of Dean, Associate Dean or Assistant Dean, as defined in Article II of the Academic Articles.","source_system":"Faculty Profile","possible_values":"N/A","notes":"The specific type of dean appointment held by an individual appears in the Dean Type field.","data_sensitivity":"N/A","data_availability":"N/A","name":"Active Dean"}'
    req.body = params[:termJSON]

    puts "\n\nreq.body: #{req.body}\n\n"


   
    response = Net::HTTP.new( Huginn::Application::CONFIG["muninn_host"], Huginn::Application::CONFIG["muninn_port"]).start do |http|
      http.request(req) 
    end
    render status: response.code, text: response.body
  end




  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

  def authenticated_show
    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]

    cas_service_uri = "https://" + muninn_host.to_s + "/"
    proxy_granting_ticket = session[:cas_pgt]
    ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(
      proxy_granting_ticket, cas_service_uri
    )

    logger.debug("Querying Muninn...")
    uri_string = "/terms/" + URI::encode(params[:id])

    muninn_response = HTTParty.get(
      #{}"http://#{muninn_host}:#{muninn_port}/#{uri_string}"
      "http://#{muninn_host}:#{muninn_port}/#{uri_string}?service=#{URI::encode(ticket.service)}&ticket=#{ticket.ticket}"
      )

    @term = JSON.parse(muninn_response.body)
    @term["huginn_user"] = session[:cas_user].to_s
  end

  def show
    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]

    logger.debug("Querying Muninn...")
                uri_string = "/terms/" + URI::encode(params[:id])
                #service_uri = "localhost:3000" + uri_string
                #logger.debug "*** SESSION KEYS ***: " + session.keys.to_s
                #proxy_granting_ticket = session[:cas_pgt]
                #logger.debug "*** PROXY GRANTING TICKET ***: " + proxy_granting_ticket
    #ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(service_uri, proxy_granting_ticket).ticket
                #logger.debug "*** ACTUAL TICKET ***: " + ticket.to_s
    http = Net::HTTP.new(muninn_host, muninn_port)
    http.use_ssl = Huginn::Application::CONFIG["muninn_uses_ssl"]
    if !Huginn::Application::CONFIG["validate_muninn_certificate"]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE #for when Muninn is using a self-signed cert
    end
    if Huginn::Application::CONFIG["muninn_uses_ssl"]
                  muninn_response = http.get("https://#{muninn_host}:#{muninn_port}/#{uri_string}")
    else
      muninn_response = http.get("http://#{muninn_host}:#{muninn_port}/#{uri_string}")
    end
                @term = JSON.parse(muninn_response.body)
  end

  def index


    logger.debug("Querying Muninn...")
   # test_string = "{ "query" : {"match_all": {}}, "from":0, "size":999}"
    #service_uri = "localhost:3000" + uri_string
    #logger.debug "*** SESSION KEYS ***: " + session.keys.to_s
    #proxy_granting_ticket = session[:cas_pgt]
    #logger.debug "*** PROXY GRANTING TICKET ***: " + proxy_granting_ticket
    #ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(service_uri, proxy_granting_ticket).ticket
    #logger.debug "*** ACTUAL TICKET ***: " + ticket.to_s

    #http = Net::HTTP.new(muninn_host, muninn_port)
    #http.use_ssl = Huginn::Application::CONFIG["muninn_uses_ssl"]
    #if !Huginn::Application::CONFIG["validate_muninn_certificate"]
      #http.verify_mode = OpenSSL::SSL::VERIFY_NONE #for when Muninn is using a self-signed cert
   # end

   if params.has_key?(:tags)
    search_s = params[:tags][:search1]
    search_string(search_s)

      # json_string = '{"query":{"query_string": {"query": "*' + "#{search_param}" +'*","fields":["name","definition"]}},"sort":[{"name":{"order":"asc"}}],"from":"0","size":"999"}'
   else
    json_string = '{"query":{"match_all":{}},"from":"0","size":"999"}'
    muninn_response_render(json_string)

   end

  end

  def search_string(search_s)
    if !search_s.blank?
       json_string =json_string ='{"query":{"match": {"_all": {"query": "' + "#{search_s}" + '" , "operator": "and"}}},"filter":{"type":{"value":"term"}},"size":"999"}'
     else
       json_string = '{"query":{"match_all":{}},"from":"0","size":"999"}'
    end

    muninn_response_render(json_string)
  end

  def partial_search
    @results = search_string( params[:q] )
      respond_to do |format|
      format.json {render :json => @results, layout: false}
      format.html {render layout: false }
    end
        #render :text => "hello", :layout => false
  end



  def muninn_response_render(json_string)
    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]

    muninn_response = HTTParty.get("http://#{muninn_host}:#{muninn_port}/search/custom/query", { :body => json_string,
    :headers => { 'Content-Type' => 'application/json'} })

   # muninn_response = http.get("https://#{muninn_host}:#{muninn_port}/#{uri_string}")
    # @output = muninn_response.body.to_json
    output_string= ActiveSupport::JSON.decode(muninn_response.body.to_json)

    @results= extract_results(output_string)

   # @results =@results.sort!{|a,b| a[:sort_name]<=> b[:sort_anme]}
    @results =@results.sort_by { |k| "#{k[:sort_name]}"}

    @results = @results.paginate(page: params[:page], per_page: 20)

   end


   def extract_results(search_response)
    response_hash = JSON.parse(search_response)
    if !response_hash.has_key?("result")
      LogTime.info("No contents.")
      return []
    end
    output = []
    response_hash["result"]["hits"]["hits"].each do |hit|
    node ={
      :id => hit["_id"].to_i,
      :type => hit["_type"],
      :score => hit["_score"],
      :data => hit["_source"],
      :sort_name =>hit["_source"]["name"]
    }
     if hit["highlight"] != nil
      if hit["highlight"]["name"] != nil
        node1  = {:m_name => hit["highlight"]["name"][0]}
        node.merge!(node1)
      end
      if hit["highlight"]["definition"] != nil
        node2 ={:m_definition => hit["highlight"]["definition"][0]}
        node.merge!(node2)
       end
    end

    output << node

    end

   return output
  end

end
