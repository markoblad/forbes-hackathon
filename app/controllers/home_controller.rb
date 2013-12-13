class HomeController < ApplicationController
  before_filter :page_exists
  
  def page_exists
    @is_homepage = self.is_homepage?
  end
  
  def is_homepage?
    request.path == '/' && request.subdomain == Settings.url.subdomain
  end


  def form_submit
    if params[:url].blank?
      Notifier.home_contact_form_submit(params).deliver
      flash[:notice] = t('home.contact.submitted.notice')
      redirect_to(:back)
    else
      flash[:notice] = t('home.contact.error.notice')
      redirect_to(:back)
    end
  end

  
  protected
  
  def _prefixes
    @_prefixes_with_partials ||= super | ["shared", "../../public/#{I18n.locale}/shared"]
  end  

  
end
