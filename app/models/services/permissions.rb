class Services::Permissions

  def self.can( role_array, action )
    case action
    when :publish_report
      role_array.include? "Report Publisher"
    end
  end

end