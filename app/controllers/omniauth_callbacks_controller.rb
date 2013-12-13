class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # include Mongoid::Document

    def all
        # user = User.from_omniauth(request.env["omniauth.auth"])
        auth = request.env["omniauth.auth"]
        user = User.where(auth.slice(:provider, :uid)).first_or_create
        user.provider = auth.provider
        user.uid = auth.uid
        user.login_params = ""#auth.to_yaml
        user.image_url = auth.info.image
        user.name = auth.info.name

        # user.update({provider: auth.provider, uid: auth.uid, login_params: auth.to_yaml, image_url: auth.info.image, name: auth.info.name })

        if user.persisted?
          flash.notice = "Signed in!"
          sign_in_and_redirect user
        else
          session["devise.user_attributes"] = user.attributes
          redirect_to new_user_registration_url
        end
    end

    alias_method :linkedin, :all
end