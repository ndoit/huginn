class GuideController < ApplicationController

  before_filter :node_types, :report_roles
  # before_filter :authenticate!, only: :search
  # before_filter :authorize, :except => [:index, :show]
  # before_filter :authorize, :only => :delete

  def node_types
    @node_types = [ 'report', 'term' ]
    # if current_user
    #   @node_types << 'report'
    # end
  end

  def report_roles
    @report_roles = []
    if current_user
      @report_roles = Muninn::SecurityRoleAdapter.all(session[:cas_user], session[:cas_pgt]).select do |k|
        k.report_role? && (current_user.has_role? k.name)
      end
    end
  end

  def index
    #checks whether any search params have been entered
    if params.has_key?(:selected_resources)
      params[:selected_resources] = params[:selected_resources].singularize
    end
  end

  def search
    logger.debug("Querying Muninn...")
    logger.debug("Params: " + params.to_s)

    params[:page] ||= 1

    @query = params[:selected_resources]
    # logger.debug("This is the params :selected_resources= #{@query}")
    query_output = Muninn::CustomSearchAdapter.typeahead(params, session[:cas_user], session[:cas_pgt])
    @results = query_output["result"]

    # logger.debug("These are the returning params: #{mcsa.to_s}")
    

    logger.debug("Ok, These are the results: '#{@results}'")

    @selected_node_types = []
    @results.each do |r|
      unless @selected_node_types.include?(r["&type"])
        @selected_node_types << r["&type"]
      end
      #for all results of type report
      if r["&type"] == "report"
        #create a new key/value pair with the PhotoMapper class
        r["photo"] = PhotoMapper.new( r["id"] )
      end
    end

    if params[:page].to_i > 1
      render partial: "partial_search", locals: { results: @results || [] }, layout: false
    else
      render html: "search", layout: false
    end
  end

  # I can't find this being used anywhere else.
  # It might be old dead code.
  # private

  # def role_filter_array
  #   if current_user
  #     current_user.security_roles
  #   else
  #     []
  #   end
  # end

end 