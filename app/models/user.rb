class User

  attr_accessor :name, :security_roles

  def initialize( netid )
    @name = netid
    @name ||= "No name found"
  end

  def security_roles
    @roles ||= get_security_roles
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
    #[ "Report Publisher" ]
    Muninn::UserAdapter.security_roles( self.name )
  end

end
