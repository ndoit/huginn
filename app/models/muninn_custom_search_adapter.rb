require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class MuninnCustomSearchAdapter

  attr_reader :selected_node_types, :results

  def initialize
    @node_types = [ 'report', 'term', 'office' ]
  end

  def prep_search( args )
    @muninn_result = query_muninn( args[:q], args[:page] )
    @selected_node_types = selected_resource_array( args )
    @results = filter_results( @muninn_result, args[:page], @selected_node_types )
  end

  def resource_count_hash()
    # get a hash of result count by node type
    results_count = @muninn_result.select { |k| "#{k[:type]}" =="doc_count"}
    results_count = results_count[0][:totalcount]
    results_hash = {}
    results_count.each do |hash|
       results_hash[hash["key"]] = hash["doc_count"]
    end
    results_hash
  end


  def raw_result
    @muninn_result
  end

  def create_search_string(search_s)
   if !search_s.blank?
     json_string ='{ "query" : { "query_string" : {"query" :  "' + "#{search_s}" + '","default_operator": "and", "fields" : ["name","definition", "description"]}},"aggs" : {"type" : {"terms" : { "field" :  "_type" }}},"from":"0","size":"999" }'
     else
       json_string = '{ "query" : { "query_string" : {"query" : "*","default_operator": "and", "fields" : ["name", "definition","description"]}},"aggs" : {"type" : {"terms" : { "field" :  "_type" }}},"from":"0","size":"999" }'
    end

    puts "query string: " + json_string
    json_string
  end


private
  def query_muninn( query_string, page_number )
    search_string = create_search_string( query_string )
    custom_query(search_string, page_number, 15 )
  end


  # no key == get all.
  # empty key == get nothing!
  def selected_resource_array( args )
    if ( args.keys.include? "selected_resources" )
      args["selected_resources"].split(",")
    else
      # get all.  return the original
      @node_types
    end
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
      output << node

    end

     totalcount = { :type => "doc_count",:totalcount => response_hash["result"]["aggregations"]["type"]["buckets"]}

     output << totalcount

  end

  def custom_query(json_string, page, per_page )
    muninn_host = ENV["muninn_host"]
    muninn_port = ENV["muninn_port"]

    muninn_response = HTTParty.get("http://#{muninn_host}:#{muninn_port}/search/custom/query", { :body => json_string,
    :headers => { 'Content-Type' => 'application/json'} })

    output_string= ActiveSupport::JSON.decode(muninn_response.body.to_json)

    results= extract_results(output_string)

   end


end
