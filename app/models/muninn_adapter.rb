class MuninnAdapter

  def self.custom_query(json_string, page, per_page )
    muninn_host = Huginn::Application::CONFIG["muninn_host"]
    muninn_port = Huginn::Application::CONFIG["muninn_port"]

    muninn_response = HTTParty.get("http://#{muninn_host}:#{muninn_port}/search/custom/query", { :body => json_string,
    :headers => { 'Content-Type' => 'application/json'} })

    output_string= ActiveSupport::JSON.decode(muninn_response.body.to_json)

    results= MuninnAdapter.extract_results(output_string)

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


end
