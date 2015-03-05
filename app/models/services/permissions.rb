class Services::Permissions

  def self.can( role_array, action )
    case action
    when :publish_report
      role_array.include? "Report Publisher"
    when :edit_term
      role_array.include? "Term Editor"
    end
  end
  
end