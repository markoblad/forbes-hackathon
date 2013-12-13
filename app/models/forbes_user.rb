class ForbesUser
  include Mongoid::Document
  field :username, type: String
  field :linkedin, type: String


#   person api:
# http://apis.forbes.com/hackathon/person/bill-gates.json?api_key=gxgpvwxya25quemzxh9r5593


# 	billionaires - does this work?
#   http://apis.forbes.com/hackathon/person/billionaires/%7Byear%7D/position/true.json?start={startNumberOfResults}&limit={totalNumberOfResults}&fields=name,age,source,residence,countryOfCitizenship,person&api_key=gxgpvwxya25quemzxh9r5593

#   billionaires 2013
#   http://apis.forbes.com/hackathon/person/billionaires/2013/position/true.json?start=0&limit=10&fields=name,age,source,residence,countryOfCitizenship,person&api_key=gxgpvwxya25quemzxh9r5593
end
