require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

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
     
     muninn_result = muninn_result( params[:q], params[:page] )
     @selected_node_types = selected_resource_array( @node_types, params )
     @results = filter_results( muninn_result, params[:page], @selected_node_types )

     @resource_count_hash = resource_count_hash( muninn_result )

     if ( params[:page].to_i > 1 )
       render partial: "terms/partial_search", locals: { results: @results || [] }, layout: false
     else
       render html: "search", layout: false
     end
 end


private

  def prep_search( params )
    muninn_result = muninn_result( params[:q], params[:page] )
    @selected_node_types = selected_resource_array( @node_types, params )
    @results = filter_results( muninn_result, params[:page], @selected_node_types )
  end

  def muninn_result( query_string, page_number )
    search_string = MuninnCustomSearchAdapter.create_search_string( query_string )
    MuninnCustomSearchAdapter.custom_query(search_string, page_number, 15 )
  end

  def resource_count_hash( raw_result )
    # get a hash of result count by node type
    results_count = raw_result.select { |k| "#{k[:type]}" =="doc_count"}
    results_count = results_count[0][:totalcount]
    results_hash = {}
    results_count.each do |hash|
       results_hash[hash["term"]] = hash["doc_count"]
    end
    results_hash
  end


  def filter_results( raw_result, page, selected_types )
    # all results, sorted and paged.
    # use the select clause to only return the desired resource types.
    # we always need to use select to avoid grabbing the "count" node.
    results = {}
    results = raw_result.select { |k| selected_types.include? "#{k[:type]}" }
                         .sort_by { |k| "#{k[:sort_name]}"}
                         .paginate(:page=> page, :per_page => 10)
  end

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
