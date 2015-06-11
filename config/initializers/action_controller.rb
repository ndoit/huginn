class ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :debug_headers
  

  private
    def debug_headers
        if request.env['HTTP_X_FORWARDED_HOST']
            request.env.except!('HTTP_X_FORWARDED_HOST') # just drop the variable
        end
    end # def



end
