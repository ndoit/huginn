require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class GuideController < ApplicationController

 def index

 end


 def search
    logger.debug("Querying Muninn...")

     page = params[:page]
     #json_string = '{"query":{"match_all":{}}, "facets": {"tags":{ "terms" : {"field" : "_type"}}},"from":"0","size":"999"}'
		 search_string = MuninnCustomSearchAdapter.create_search_string( params[:q] )

     @query_result = MuninnCustomSearchAdapter.custom_query(search_string, page, 15 )

     # divide up results
     @node_types = [ 'report', 'term', 'office' ]
     @results = {}


    @selected_node_types = selected_resource_array( @node_types, params )

     # all results, sorted and paged.
     # use the select clause to only return the desired resource types.
     # we always need to use select to avoid grabbing the "count" node.
     @results = @query_result.select { |k| @selected_node_types.include? "#{k[:type]}" }
                             .sort_by { |k| "#{k[:sort_name]}"}
                             .paginate(:page=> page, :per_page => 10)



     # get a hash of result count by node type
     @results_count = @query_result.select { |k| "#{k[:type]}" =="count"}
     @results_count = @results_count[0][:totalcount]
     @results_hash = {}
     @results_count.each do |hash|
        @results_hash[hash["term"]] = hash["count"]
     end

     render html: "search", layout: false
 end


private

  # no key == get all.
  # empty key == get nothing!
  def selected_resource_array( node_types, params )
    if ( params.keys.include? "selected_resources" )
      params["selected_resources"].split(",")
    else
      # get all.  return the original
      node_types
    end
  end
end
