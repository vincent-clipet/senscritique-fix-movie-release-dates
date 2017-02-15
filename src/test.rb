require 'nokogiri'



sc_html = File.open("SC/moonlight.html") { |f| Nokogiri::HTML(f) }
id_imdb = sc_html.at_css('#scwiki-imdb-id').parent.at_css("ul > li > div").text.strip




imdb_html = File.open("IMDB/example.html") { |f| Nokogiri::HTML(f) }

french_release = nil
international_release = nil

imdb_html.css("#release_dates > tbody > tr").each do | tr |
	
	country = tr.css("td")[0].text
	release_date = tr.css("td")[1].text
	comment = tr.css("td")[2].text

	next if comment != ""

	if (international_release.nil?)
		international_release = release_date
	end

	if (french_release.nil? && country == "France")
		french_release = release_date
	end

	break unless (french_release.nil? || international_release.nil?)

end

puts "France : #{french_release}"
puts "International : #{international_release}"