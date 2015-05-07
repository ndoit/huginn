require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class ReportsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  skip_before_action :verify_authenticity_token

  def update
    logger.debug("JSON sent to muninn: #{params[:reportJSON]}")
    logger.debug("#####################################")
    logger.debug("params sent to Muninn Again + #{params}")
    response = Muninn::Adapter.put( "/reports/params[:name]", session[:cas_user], session[:cas_pgt], params[:reportJSON] )

    render status: response.code, json: response.body
  end

  def tableau_parse( text )
    @tableau_parse = {}
    if text.present?
      a = text.match(/width=\'([^"]*?)\'/)
      @tableau_parse["width"] = a.try{ |p| p[1] }
      b = text.match(/height=\'([^"]*?)\'/)
      @tableau_parse["height"] = b.try{ |p| p[1] }
      c = text.match(/'name' value=\'([^"]*?)\'/)
      @tableau_parse["name"] = c.try{ |p| p[1] }
      d = text.match(/'tabs' value=\'([^"]*?)\'/)
      @tableau_parse["tabs"] = d.try{ |p| p[1] }
    end
    return @tableau_parse
  end


  def create
    response = Muninn::Adapter.post( '/reports/', session[:cas_user], session[:cas_pgt], params[:report])
    render status: response.code, json: response.body
  end

  def destroy
    logger.debug("#####################################")
    logger.debug("params sent to Muninn Again + #{params}")
    response = Muninn::Adapter.delete( "/reports/id/" + params[:id], session[:cas_user], session[:cas_pgt] )
    render status: response.code, json: response.body
  end

  def show

    logger.debug("Querying Muninn...")
    reports_resp = Muninn::Adapter.get( 
      "/reports/" + URI::encode(params[:id]),
      session[:cas_user], session[:cas_pgt]
    )
    @report = JSON.parse(reports_resp.body)
    logger.debug("checking report success: #{@report["success"]}")
    logger.debug("full report hash: #{@report}")
    if @report["success"] 

      @report_photo = PhotoMapper.new( @report["report"]["id"], @report["report"]["timestamp"].present? ? @report["report"]["timestamp"] : nil )

      ## GET Report's Associated Terms
      term_report_json = @report["terms"]
      if term_report_json  != nil
        term_report = []
        term_report_json.each do |term|
          term_report << {id: term["id"], text: term["name"]}
        end
        @term_reports = term_report.to_json
        # logger.debug("these are the report's terms: #{@report["terms"]}")
      end

      ## GET Report's Associated Security Access
      roles_report_origin = @report["allows_access_with"]
      @roles_report_origin = roles_report_origin
      
      if roles_report_origin.present?
        @report_roles = []
        roles_report_origin.each do |role|
          @report_roles << {id: role["id"], text: role["name"]}
        end
        @report_roles_json = @report_roles.to_json
      end

      ## GET subreport?
      if @report["report"]["report_type"] == "Aggregation" || @report["report"]["report_type"] == "External" then
        if @report["report"]["embedJSON"].present?
          @report_embed = JSON.parse @report["report"]["embedJSON"]
          if @report["report"]["report_type"] == "Aggregation"
            logger.debug("Aggregation report requested, querying sub-reports...")
            @subreports = []
            if @report_embed["subreports"].present?
              @report_embed["subreports"].each do |subreport_name|
                logger.debug("Querying for " + subreport_name + "...")
                subreport_response = Muninn::Adapter.get("/reports/" + URI::encode(subreport_name), session[:cas_user], session[:cas_pgt])
                subreport_json = JSON.parse(subreport_response.body)
                @subreports << { "name" => subreport_json["report"]["name"], "thumbnail_uri" => subreport_json["report"]["thumbnail_uri"] }
              end
            end
          end
        end
      end

       # GET All Terms
      terms_resp = Muninn::Adapter.get( "/terms", session[:cas_user], session[:cas_pgt])
      terms_json = JSON.parse(  terms_resp.body )["results"]

      terms= []
      terms_json.each do |term|
        terms << {id: term["data"]["id"], text: term["data"]["name"]}
      end
      @term_gov_json = terms.to_json

      # GET All Security Access
      roles_resp = Muninn::Adapter.get( "/security_roles", session[:cas_user], session[:cas_pgt])
      @roles_json = JSON.parse( roles_resp.body )["results"]

      @roles= []
      @roles_json.each do |role|
        unless role["data"]["name"] == "Term Editor"
          unless role["data"]["name"] == "Report Publisher"
            unless role["data"]["name"] == "Administrator"
              @roles << {id: role["data"]["id"], text: role["data"]["name"]}
            end
          end
        end
      end
      @security_roles_json = @roles.to_json
      # logger.debug("\n muninn's security_roles: #{@security_roles_json}")

      ## GET all offices
      offices_resp = Muninn::Adapter.get( "/offices", session[:cas_user], session[:cas_pgt])
      offices_json = JSON.parse(  offices_resp.body )["results"]

      @offices = []
      offices_json.each do |office|
        @offices << {id: office["data"]["id"], text: office["data"]["name"]}
      end
      # @offices_gov_json = @offices.to_json
      if @report["offices"].first then
          @report_office_owner_name = @report["offices"].first["name"]
          @report_office_owner_stake =  @report["offices"].first["stake"]
      else
          @report_office_owner = nil
      end
      # tableau parsing
      @tableau_parse = tableau_parse(@report["report"]["tableau_link"])
    end

  end

  # TEST TEST TEST
  def upload_test
  end

  def upload
    r = PhotoMapper.new( params[:id] )
    r.uploader = params[:image]
    r.save
    logger.info("image upload method ran: #{r}")
    redirect_to :back
  end
  # TEST TEST TEST

end
