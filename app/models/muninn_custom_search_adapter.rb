class MuninnCustomSearchAdapter

  def self.custom_query(json_string, page, per_page )
    muninn_host = ENV["muninn_host"]
    muninn_port = ENV["muninn_port"]

    muninn_response = HTTParty.get("http://#{muninn_host}:#{muninn_port}/search/custom/query", { :body => json_string,
    :headers => { 'Content-Type' => 'application/json'} })

    output_string= ActiveSupport::JSON.decode(muninn_response.body.to_json)

    results= MuninnCustomSearchAdapter.extract_results(output_string)

    results = results.sort_by { |k| "#{k[:sort_name]}"}

    results.paginate(page: page, per_page: per_page)

   end



  def self.extract_results(search_response)
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
      if hit["highlight"] != nil
        if hit["highlight"]["name"] != nil
          node1  = {:m_name => hit["highlight"]["name"][0]}
          node.merge!(node1)
        end
        if hit["highlight"]["definition"] != nil
          node2 ={:m_definition => hit["highlight"]["definition"][0]}
          node.merge!(node2)
        end
      end

      output << node

    end

    return output

  end



  def self.create_search_string(search_s)
    if !search_s.blank?
       json_string =json_string ='{"query":{"match": {"_all": {"query": "' + "#{search_s}" + '" , "operator": "and"}}},"filter":{"type":{"value":"term"}},"from":"0","size":"999"}'
     else
       json_string = '{"query":{"match_all":{}},"from":"0","size":"999"}'
    end

  end

end
