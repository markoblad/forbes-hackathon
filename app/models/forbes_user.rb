class ForbesUser


	require 'rubygems'
	require 'uri'
	require 'open-uri'
	require 'rest-client'
	require 'text'

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


	# h["organizationList"]["organizationsLists"][0]
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

	# reload!; a = ForbesUser::get_articles
	def self.get_articles(opts={})
		options = {
			limit: 1000
		}.merge(opts)
		hash = {}
		url = "http://apis.forbes.com/hackathon/contents/stream/all/all.json?limit=#{options[:limit]}&api_key=gxgpvwxya25quemzxh9r5593"
		json = RestClient.get url
		hash = JSON.parse(json)
		return hash
	end

	# reload!; ns = ForbesUser::return_closest_levenshtein_names("mark", ["marko", "paul", "markoblad", "marka", "karma", "ramk", "marc", "marco", "gram"])
	def self.return_closest_levenshtein_names(name, names)
		levenshtein_names = []
		unless name.blank? || names.blank?
			if names.size == 1
				levenshtein_names = names
			else
				cleaned_target_name = name.upcase.gsub(/[^[[:word:]]\s]/, ' ').strip
				distances = []
				names.each do |possible_match_name|
					cleaned_possible_match_name = possible_match_name.upcase.gsub(/[^[[:word:]]\s]/, ' ').strip
					distances << Text::Levenshtein.distance(cleaned_possible_match_name, cleaned_target_name)
				end
				distance_min = distances.min
				levenshtein_min_indexes = distances.each_with_index.select {|distance, index| distance == distance_min}
				levenshtein_min_indexes.compact! unless levenshtein_min_indexes.blank?
				unless levenshtein_min_indexes.blank?
					levenshtein_names = levenshtein_min_indexes.collect {|distance, index| names[index]}
				end
			end
		end
		return levenshtein_names
	end

	# reload!; ns = ForbesUser::return_closest_white_names("mark", ["marko", "paul", "markoblad", "marka", "karma", "ramk", "marc", "marco", "gram"])
	def self.return_closest_white_names(name, names)
		white_names = []
		unless names.blank?
			if names.size == 1
				white_names = names
			else
				cleaned_target_name = name.upcase.gsub(/[^[[:word:]]\s]/, ' ').strip
				similitudes = []
				names.each do |possible_match_name|
					cleaned_possible_match_name = possible_match_name.upcase.gsub(/[^[[:word:]]\s]/, ' ').strip
					white = Text::WhiteSimilarity.new
					similitudes << white.similarity(cleaned_possible_match_name, cleaned_target_name)
				end
				similitude_max = similitudes.max
				white_max_indexes = similitudes.each_with_index.select {|similitude, index| similitude == similitude_max}
				white_max_indexes.compact! unless white_max_indexes.blank?
				unless white_max_indexes.blank?
					white_names = white_max_indexes.collect {|similitude, index| names[index]}
				end
			end
		end
		return white_names
	end

end
