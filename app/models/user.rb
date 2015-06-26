require 'json'
class User

  attr_accessor :name, :old_security_roles
  attr_reader :my_access, :admin_emeritus, :user_name, :security_roles

  def initialize( netid, cas_user, cas_pgt )
    @name = netid
    @name ||= "No name found"
    @my_access = Muninn::SecurityRoleAdapter.my_access( @name )
  end

  def my_roles
    @my_roles = []
    @my_access["user"]["roles"].each do |ur|
      @my_roles << ur[0]
    end
    @my_roles
  end

  def default_admin_roles
    @default_admin_roles = JSON.parse(File.read('public/assets/base_user_roles.json'))
    @default_admin_roles.to_s
  end

  def has_role?( role )
    @my_roles.include? role
  end

  def is_admin?
    @my_access["user"]["is_admin"]
  end

  def list_create_access
    @list_create_access = @my_access["user"]["create_access_to"]
  end

  def has_create_access_to( node_type )
    list_create_access.include? node_type
  end

  def list_read_access
    @list_read_access = @my_access["user"]["read_access_to"]
  end

  def has_read_access_to( node_type )
    list_read_access.include? node_type
  end


  ## Currently my_access does not return admin_emeritus field
  # def admin_emeritus?
  #   @my_access["user"]["admin_emeritus"]
  # end

  def user_name
    @my_access["user"]["net_id"]
  end

  def can( action )
    if is_admin?
      return true
    else
      case action
      when :publish_report
        has_create_access_to( "report" ) 
      when :edit_term
        has_create_access_to( "term" )
      end
    end
  end

end
