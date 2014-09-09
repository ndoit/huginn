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
     @node_types.each do |type_name|

       @results[type_name] = @query_result.select { |k| "#{k[:type]}" == type_name }
                                          .sort_by { |k| "#{k[:sort_name]}"}
                                          .paginate(:page=> page, :per_page => 15)

     end

     # all results, sorted and paged.
     # still need the select clause b/c of the "count" type node.
     @results = @query_result.select { |k| @node_types.include? "#{k[:type]}" }
                             .sort_by { |k| "#{k[:sort_name]}"}
                             .paginate(:page=> page, :per_page => 15)



     # get a hash of result count by node type
     @results_count = @query_result.select { |k| "#{k[:type]}" =="count"}
     @results_count = @results_count[0][:totalcount]
     @results_hash = {}
     @results_count.each do |hash|
        @results_hash[hash["term"]] = hash["count"]
     end

     render html: "search", layout: false
 end

end
