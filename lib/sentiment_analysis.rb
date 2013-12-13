module SentimentAnalysis

	# def self.scrub_entries(text_array)
	# 	scrubbed_text_array = []
	# 	text_array.each do |x|
	# 		scrubbed_text_array << Loofah.fragment(x).scrub!(:whitewash).to_s
	# 	end
	# 	return scrubbed_text_array
	# end

	def self.sentiment_calculator(text_block, opts={})
		options = {}.merge(opts)
		# sentiment_hash = {}
		# raw_scores = []
		# sentiment_details = []
		# text_array.each do |item|
			raw_score = $analyzer.get_score text_block
			sentiment_detail = $analyzer.get_sentiment text_block
			# raw_scores << raw_score
			# sentiment_details << sentiment_detail
		# end
		# sentiment_score = (raw_scores.inject(0.0) { |sum, element| sum + element } / raw_scores.size)
		# sentiment_hash = {:score => sentiment_score, :sentiment_details => sentiment_details}
		return raw_score || 0.0
	end
end