class PaymentsController <  ActionController::Base
  append_view_path Rails.root.join("/app/views")
  layout 'application'
  
  def new
  end
end
