class SecurityRole

  attr_reader :id, :role_eds_code, :is_public, :name

  def initialize(args)
    @id = args["id"]
    @role_eds_code = args["role_eds_code"]
    @is_public = args["is_public"]
    @name = args["name"]
  end

end
