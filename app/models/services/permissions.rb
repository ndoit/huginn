class Services::Permissions

  def self.can( user_role_access, action )
    case action
    when :publish_report
      user_role_access.include? "Report Publisher"
    when :edit_term
      user_role_access.include? "Term Editor"
    end
  end

  # def self.can( node_security_role, node_action )
  #   case node_action
  #   when :
  # end

end