class ForbesUser


	require 'rubygems'
	require 'uri'
	require 'open-uri'
	require 'rest-client'

  include Mongoid::Document
  field :username, type: String
  field :linkedin, type: String


#   person api:
# http://apis.forbes.com/hackathon/person/bill-gates.json?api_key=gxgpvwxya25quemzxh9r5593


# 	billionaires - does this work?
#   http://apis.forbes.com/hackathon/person/billionaires/%7Byear%7D/position/true.json?start={startNumberOfResults}&limit={totalNumberOfResults}&fields=name,age,source,residence,countryOfCitizenship,person&api_key=gxgpvwxya25quemzxh9r5593

#   billionaires 2013
#   http://apis.forbes.com/hackathon/person/billionaires/2013/position/true.json?start=0&limit=10&fields=name,age,source,residence,countryOfCitizenship,person&api_key=gxgpvwxya25quemzxh9r5593

# top 20 all articles
# http://apis.forbes.com/hackathon/contents/stream/all/all.json?fields=uri,naturalId,generatedId,tickers,type,date,body,authors,title,description,image,blogType,slides,commentCount,calledOutCommentCount,magazine,manualDescription&limit=20&api_key=gxgpvwxya25quemzxh9r5593

# http://apis.forbes.com/hackathon/org/global2000/2013/position/true.json?start=0&limit=2000&api_key=gxgpvwxya25quemzxh9r5593

# http://apis.forbes.com/hackathon/org/oracle.json?api_key=gxgpvwxya25quemzxh9r5593


	# reload!; h = ForbesUser::get_company_list(2013)
	def self.get_company_list(year, opts={})
		options = {
			start: 0,
			count: 2000
		}.merge(opts)
		hash = {}
		unless year.blank?
			url = "http://apis.forbes.com/hackathon/org/global2000/#{year.to_s}/position/true.json?start=#{options[:start].to_s}&limit=#{options[:count].to_s}&api_key=gxgpvwxya25quemzxh9r5593"
			json = RestClient.get url
			hash = JSON.parse(json)
		end
		return hash
	end

	# reload!; c = ForbesUser::get_company_content("Iliad")
	def self.get_company_content(company, opts={})
		options = {
		}.merge(opts)
		hash = {}
		unless company.blank?
			formatted_company = company.downcase.gsub(/\s+/, '-')
			url = "http://apis.forbes.com/hackathon/org/#{formatted_company}.json?api_key=gxgpvwxya25quemzxh9r5593"
			json = RestClient.get url
			hash = JSON.parse(json)
		end
		return hash
	end

end
