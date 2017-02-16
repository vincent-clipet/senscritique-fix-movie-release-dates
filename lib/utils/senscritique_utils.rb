module SenscritiqueUtils



	# Get the wiki page URL from the main page URL
	def self.get_wiki_url(sc_movie_url)
		return sc_movie_url.gsub(/\/film\//, "/wiki/")
	end



	# Get IMDB id currenty saved for this movie
	# @param sc_html [Nokogiri::HTML] HTML page from Senscritique, who may contain IMDB id
	# @return [String, nil] current IMDB id. Can be nil if not found.
	def self.get_wiki_imdb_id(sc_html)
		id_imdb = sc_html.at_css('#scwiki-imdb-id').parent.at_css("ul > li > div").text.strip
		return nil if id_imdb == ""
		return id_imdb
	end



	# Get a movie International release date & French release date
	# @param sc_html [Nokogiri::HTML] HTML page from Senscritique, who may contain both release dates
	# @return [Array] containing both international release date & french release date. Both dates can be nil.
	def self.get_wiki_release_dates(sc_html)
		french_date_str = sc_html.at_css("#scwiki-releasedate").parent.at_css("ul > li > div").text
		international_date_str = sc_html.at_css("#scwiki-originalreleasedate").parent.at_css("ul > li > div").text
		return [ get_date_from_string(international_date_str), get_date_from_string(french_date_str) ]
	end



	# Get day/month/year for Senscritique wiki form
	# @param date [Date]
	# @return [Array] containing the 3 values to input in wiki form
	def self.split_date(date)
		return [date.day, date.month, date.year]
	end



	private



	# Convert a date string coming from the release dates page to a usable Date object
	# @param date_str [String] Date string from Senscritique wiki page
	# @return [Date, nil]
	def self.get_date_from_string(date_str)
		return nil if date_str.nil?
		return Date.strptime(date_str, '%d/%m/%Y')
	end



end