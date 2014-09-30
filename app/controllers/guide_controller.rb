class GuideController < ApplicationController

  before_filter :node_types

 def node_types

   @node_types = [ 'term', 'report' ]
   #if current_user
   # @node_types << "report"
   #end

   @security_roles = Muninn::SecurityRoleAdapter.all
 end

 def index

 end

 def search
     logger.debug("Querying Muninn...")

     params[:page] ||= 1

     mcsa = Muninn::CustomSearchAdapter.new( params )
     mcsa.filter_reports( current_user.security_roles )
         .filter_results

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

end
