class SecurityRole

  attr_reader :id, :role_eds_code, :is_public, :name

  def initialize(args)
    @id = args["id"]
    @role_eds_code = args["role_eds_code"]
    @is_public = args["is_public"]
    @name = args["name"]
    @report_role = args["report_role"]
  end

  def report_role?
  	@report_role == 'Y'
  end

end
