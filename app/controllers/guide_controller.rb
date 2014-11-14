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
      @report_roles = Muninn::SecurityRoleAdapter.all.select do |k|
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

    params[:page] ||= 1


    mcsa = Muninn::CustomSearchAdapter.new( params )
    #mcsa.filter_reports( role_filter_array )
    mcsa.filter_results

    @results = mcsa.results


# Right now the results are coming in and only getting parsed at the view layer. If I want to add authentication on certain terms and reports, I would need to parse out the terms and reports here at the controller/model level BEFORE sending it to the view. 

# each time the user hits muninn, muninn retrieves everything and then sends it back


    # @report_photos = Array.new



 
    # logger.debug("Ok, These are the results:' #{@results}'")


    @reports = @results.select { |k| k["type"] =="report"}
    # logger.debug("************THIS IS EVEN NEWER **************")
    # logger.debug("Ok, These are the results: #{@results}")
    # logger.debug("And these are the reports: #{@reports}")
    # @arrayed_results = @results.split(",")
    # logger.debug("Arrayed results: #{@arrayed_results}")
    # @arrayed_reports = @arrayed_results.select { |k| k["type"] == "reports"}
    
    # logger.debug("Arrayed Reports: #{@arrayed_reports}")



    # logger.debug("We're gonna try parsing the results: #{@results.split(",")}")

    # logger.debug("Now these are the report items in unparsed results: #{@reports}")
    # @arrayed_results = @results.split(",")

    # logger.debug("@results is a :#{@results.singleton_class}")
    #= > @results is a :#<Class:#<WillPaginate::Collection:0x00000006a8bc80>>

    # @reports = @arrayed_results.select { |k| k[:type] =="report"}

    # logger.debug("and finally we should hopefully have parsed reports: #{@reports}")


    


    # @reports.each do |r|
    #   @report_photos << ReportPhoto.new( r["id"])
    # end


    @muninn_result = mcsa.raw_result

    # logger.debug("Ok, These are the muninnresults:' #{@muninn_result}'")

    @selected_node_types = mcsa.selected_node_types  # should the mcsa do this
    @resource_count_hash = mcsa.resource_count_hash


    # render "filter_count_nav_bar.html.erb"
    if ( params[:page].to_i > 1 )
      render partial: "partial_search", locals: { results: @results || [] }, layout: false
    else
      render html: "search", layout: false
    end
  end

  private

  def role_filter_array
    if current_user
      current_user.security_roles
    else
      []
    end
  end

end
