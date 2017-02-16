module ImdbUtils

	require 'date'



	# Get the release page URL from movie ID
	def self.get_url(imdb_id)
		return "http://www.imdb.com/title/#{imdb_id}/releaseinfo?ref_=tt_dt_dt"
	end



	# Get a movie International release date & French release date
	# @param imdb_html [Nokogiri::HTML] HTML page from IMDB, containing all release dates
	# @return [Array] containing both international release date & french release date. Both dates can be nil.
	def self.get_release_dates(imdb_html)

		international_release, french_release = nil

		imdb_html.css("#release_dates > tr").each do | tr |
			country = tr.css("td")[0].text
			release_date_str = tr.css("td")[1].text
			comment = tr.css("td")[2].text

			# current row is a festival or partial release
			next if comment != ""

			# Still looking for the first non-festival international release date
			international_release = get_date_from_string(release_date_str) if international_release.nil?

			# Still looking for the first non-festival french release date
			french_release = get_date_from_string(release_date_str) if (french_release.nil? && country == "France")

			# both release dates were found
			break unless (french_release.nil? || international_release.nil?)
		end

		return international_release, french_release

	end



	private



	# Convert a date string coming from the release dates page (which is in English) to a usable Date object
	# @param date_str [String] Date string from IMDB
	# @return [Date, nil]
	def self.get_date_from_string(date_str)
		return nil if date_str.nil?
		return Date.strptime(date_str, '%d %b %Y')
	end



end