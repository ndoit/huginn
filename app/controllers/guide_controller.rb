class GuideController < ApplicationController

  before_filter :node_types, :report_roles

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
    if params.has_key?(:selected_resources)
      params[:selected_resources] = params[:selected_resources].singularize
      @current_user
    end
  end

  def search
    logger.debug("Querying Muninn...")

    params[:page] ||= 1

    mcsa = Muninn::CustomSearchAdapter.new( params )
    #mcsa.filter_reports( role_filter_array )
    mcsa.filter_results

    @results = mcsa.results
    @muninn_result = mcsa.raw_result
    @selected_node_types = mcsa.selected_node_types  # should the mcsa do this
    @resource_count_hash = mcsa.resource_count_hash

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
