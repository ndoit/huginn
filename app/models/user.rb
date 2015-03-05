class User

  attr_accessor :name, :security_roles

  def initialize( netid, cas_user, cas_pgt )
    @name = netid
    @name ||= "No name found"
    @user_obj = Muninn::Adapter.get( "/users/" + URI::encode( netid ), cas_user, cas_pgt )
  end

  def security_roles
    @roles ||= get_security_roles
  end

  def user_obj
    @user_obj
  end

  def has_role?( role )
    security_roles.include? role
  end

  def can( action )
    Services::Permissions.can( security_roles, action )
  end

  private

  def get_security_roles
    # call web service
    Muninn::UserAdapter.security_roles( self.name )
  end

end
