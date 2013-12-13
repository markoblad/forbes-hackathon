APP_NAME = 'forbes_hackathon'

# ------------------------------------------------------------
#
#  APP_URL
#
# ------------------------------------------------------------

url = Settings.url.protocol
if Settings.url.subdomain
  url += Settings.url.subdomain + '.' + Settings.url.host
else
  url += Settings.url.host
end
ENV['APP_URL'] = url