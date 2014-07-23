require "net/http"
require "json"
require "open-uri"
require "httparty"
require "will_paginate/array"

class GuideController < ApplicationController
	
def index

   logger.debug("Querying Muninn...")

   if params.has_key?(:tags)
     search_s = params[:tags][:search1]
     page =params[:page]
    json_string = MuninnCustomSearchAdapter.create_search_string(search_s)
    @results = MuninnCustomSearchAdapter.custom_query(json_string, page, 15 )

   else
    json_string = '{"query":{"match_all":{}}, "facets": {"tags":{ "terms" : {"field" : "_type"}}},"from":"0","size":"999"}'
    @results = MuninnCustomSearchAdapter.custom_query(json_string, page, 15 )
  end

     #@results= @results.sort_by { |k| "#{k[:type]}#,#{k[:sort_name]}"}

    @results_office= @results.select { |k| "#{k[:type]}" =="office"}
    @results_office = @results_office.sort_by { |k| "#{k[:sort_name]}"}
    @results_office =@results_office.paginate(:page=> page, :per_page => 15)

    @results_term= @results.select { |k| "#{k[:type]}" =="term"}
    @results_term= @results_term.sort_by { |k| "#{k[:sort_name]}"}
    @results_term= @results_term.paginate(:page=> page, :per_page => 15)
    @results_count = @results.select { |k| "#{k[:type]}" =="count"}
    #@results_count=@results_count.select { |k| "#{k[:totalcount]}" }



    @results_count = @results_count[0][:totalcount]
    @results_hash = {}
    @results_count.each do |hash|
       @results_hash[hash["term"]] = hash["count"]
    end

 end
end
