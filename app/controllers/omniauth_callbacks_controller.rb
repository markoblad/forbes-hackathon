class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # include Mongoid::Document

# require 'linkedin'

    def all
        # user = User.from_omniauth(request.env["omniauth.auth"])
        auth = request.env["omniauth.auth"]
        user = User.where(auth.slice(:provider, :uid)).first_or_create
        user.provider = auth.provider
        user.uid = auth.uid
        user.login_params = ""#auth.to_yaml
        user.image_url = auth.info.image
        user.name = auth.info.name
        user.profile_url = auth.info.urls.public_profile

        api_key = '75s8wwd8qcu4l0'
        api_secret = 'BvMmXQBAoBfy3xYz'
        user_token = '8a737d18-a614-40c2-a8ee-8ceafaee7202'
        user_secret = 'b0679e09-0023-4c7a-aee2-3c0c7872400e'
         
        # Specify LinkedIn API endpoint
        configuration = { :site => 'https://api.linkedin.com' }
         
        # Use your API key and secret to instantiate consumer object
        consumer = OAuth::Consumer.new(api_key, api_secret, configuration)
         
        # Use your developer token and secret to instantiate access token object
        access_token = OAuth::AccessToken.new(consumer, user_token, user_secret)
         
        # Make call to LinkedIn to retrieve your own profile
        response = access_token.get("http://api.linkedin.com/v1/people/~:(connections:(id,first-name,last-name,picture-url,headline,site-standard-profile-request:(url),positions:(company)))?format=json")

        json = JSON.parse(response.body)
        parsed_connections = [];
        
        json["connections"]["values"].each do |connection|
            parsed_connections << {
                "name" => "#{connection['firstName']} #{connection['lastName']}",
                "headline" => connection['headline'], 
                "image_url" => connection['pictureUrl'], 
                "linkedin_url" => connection['siteStandardProfileRequest']['url'],
                "positions" => connection['positions']['values'],
                "company" => begin connection["positions"]["values"][0]["company"]["name"] rescue nil end
            } 
        end


        user.connections = parsed_connections

        #     url = "http://api.linkedin.com/v1/people/url=http%3A%2F%2Fwww.linkedin.com%2Fpub%2Fjoshua-martin%2F86%2F918%2F863/connections?oauth_token=75--fbafc2b6-26bc-448e-85d2-f8e04b6c2ea6&oauth_verifier=718798"
        #     xml = RestClient.get url
        #     hash = XML.parse(xml)

        #     raise hash.to_yaml
        # client = LinkedIn::Client.new('your_consumer_key', 'your_consumer_secret')
        # rtoken = client.request_token.token
        # rsecret = client.request_token.secret

        # raise client.profile.to_yaml

        # user.save


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