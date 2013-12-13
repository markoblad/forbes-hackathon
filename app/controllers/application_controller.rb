class ApplicationController < ActionController::Base
  protect_from_forgery
  if Rails.env.development?
    before_filter :reload_settings
  end
  
  def after_sign_in_path_for(resource)
    #
  end

  
  protected

  def reload_settings
    Settings.reload!
  end

end
