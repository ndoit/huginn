require 'json'
class User

  attr_accessor :name, :old_security_roles
  attr_reader :user_obj, :admin_emeritus, :user_name, :security_roles

  def initialize( netid, cas_user, cas_pgt )
    @name = netid
    @name ||= "No name found"
    @user_obj = Muninn::Adapter.get( "/users/" + URI::encode( netid ), cas_user, cas_pgt )
  end

  def security_roles
    @user_obj["security_roles"]
  end

  def default_admin_roles
    @default_admin_roles = JSON.parse(File.read('public/assets/base_user_roles.json'))
    @default_admin_roles.to_s
  end

  def has_role?( role )
    security_roles.include? role
  end

  def admin_emeritus?
    @user_obj["user"]["admin_emeritus"]
  end

  def user_name
    @user_obj["user"]["net_id"]
  end

  def old_security_roles
    @roles ||= get_security_roles
  end

  def can( action )
    Services::Permissions.can( old_security_roles, action )
  end

  private

  def get_security_roles
    # call web service
    Muninn::UserAdapter.security_roles( self.name )
  end

end
