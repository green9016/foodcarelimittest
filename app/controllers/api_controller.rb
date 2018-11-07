class ApiController < ActionController::Base
  
  def i18n
    # locale param was defined in config/routes.rb
    render file: "app/assets/i18n/" + params['locale']
  end

  def datatable
    render file: "app/assets/api/datatable.json"
  end

  def xeditablegroups
    render file: "app/assets/api/xeditable-groups.json"
  end

  def xeditable
    render :nothing => true
  end

end
