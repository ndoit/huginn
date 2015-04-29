class Muninn::SecurityRoleAdapter

  # MUNINN RESPONSE IS VERY DIFFERENT WHEN ASKING FOR ONE RECORD VS ALL

  # attr_reader :my_access
  
  def self.one( id, cas_user, cas_pgt )
    resp = Muninn::Adapter.get( "/security_roles/id/" + id.to_s, cas_user, cas_pgt )
    if ( resp.code == "200" )
      j = JSON.parse(resp.body)
      Muninn::SecurityRoleAdapter.convert_to_security_roles( j )
    end
  end

  def self.all( cas_user, cas_pgt )
    resp = Muninn::Adapter.get( "/security_roles/", cas_user, cas_pgt )
    j = JSON.parse(resp.body)
    Muninn::SecurityRoleAdapter.convert_to_security_roles( j["results"] )
  end

  def self.my_access(cas_user)
    response = HTTParty.get("http://" + ENV["muninn_host"] + ":" + ENV["muninn_port"] + "/my_access?cas_user=" + cas_user )
    @my_access = JSON.parse(response.body)
  end

  def self.convert_to_security_roles( result_hash )
    #result_hash = Array(result_hash)
    objs = []

    if result_hash.class == Array
      result_hash.each do |role|
        objs << SecurityRole.new( role["data"] )
      end
    else
      objs << SecurityRole.new( result_hash["security_role"] )
    end

    objs
  end


end
