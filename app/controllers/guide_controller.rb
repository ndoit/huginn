class GuideController < ApplicationController

  before_filter :node_types

 def node_types
   @node_types = [ 'report', 'term', 'office' ]
 end

 def index

 end

 def search
     logger.debug("Querying Muninn...")

     params[:page] ||= 1

     mcsa = MuninnCustomSearchAdapter.new
     @results = mcsa.prep_search( params )
     @muninn_result = mcsa.raw_result
     @selected_node_types = mcsa.selected_node_types  # should the mcsa do this
     @resource_count_hash = mcsa.resource_count_hash

     if ( params[:page].to_i > 1 )
       render partial: "terms/partial_search", locals: { results: @results || [] }, layout: false
     else
       render html: "search", layout: false
     end
 end

end
