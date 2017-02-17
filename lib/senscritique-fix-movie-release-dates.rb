require 'nokogiri'
require 'mechanize'
require 'rest-client'
require 'logger'

require_relative 'utils/imdb_utils'
require_relative 'utils/senscritique_utils'
require_relative 'utils/http_utils'
require_relative '../config/config.rb'





##########
# PARAMS #
##########

sc_url = ARGV[0]

unless sc_url
	puts "[ERROR] Missing parameter : 'sc_url'"
	exit 1
end





########
# MAIN #
########

logger = Logger.new(STDOUT)
logger.formatter = proc {|severity, datetime, progname, msg| "[#{severity}] #{msg}\n" }
logger.level = Config::LOG_LEVEL
logger.info("sc_url = #{sc_url}")

user_agent = "senscritique-fix-movie-release-dates/1.0 (+https://github.com/vincent-clipet/senscritique-fix-movie-release-dates)"

# Get current info on SC
# ----------------------

sc_wiki_url = SenscritiqueUtils.get_wiki_url(sc_url)
sc_html = Nokogiri::HTML(HttpUtils.get(sc_wiki_url, Config::SC_COOKIES, user_agent).to_s)
logger.debug("sc_wiki_url = #{sc_wiki_url}")

sc_imdb_id = SenscritiqueUtils.get_wiki_imdb_id(sc_html)
logger.info("sc_imdb_id = #{sc_imdb_id}")
sc_international_release_date, sc_french_release_date = SenscritiqueUtils.get_wiki_release_dates(sc_html)
logger.info("sc_international_release_date = #{sc_international_release_date}")
logger.info("sc_french_release_date = #{sc_french_release_date}")

# No IMDB id found on SC' wiki page
exit 1 if sc_imdb_id.nil?



# Get both release dates on IMDB
# ------------------------------

imdb_url = ImdbUtils.get_url(sc_imdb_id)
imdb_html = Nokogiri::HTML(HttpUtils.get(imdb_url.to_s, {}, user_agent))
logger.debug("imdb_url = #{imdb_url}")

imdb_international_release_date, imdb_french_release_date = ImdbUtils.get_release_dates(imdb_html)
logger.info("imdb_international_release_date = #{imdb_international_release_date}")
logger.info("imdb_french_release_date = #{imdb_french_release_date}")



# Send new info to SC
# -------------------

# Skip form upload, except for debug mode
exit 0 if Config::SKIP_FORM_UPLOAD && logger.level != Logger::DEBUG
	
# Create Mechanize instance
mech = Mechanize.new()
mech.user_agent = user_agent

# Add all needed cookies
HttpUtils.add_sc_cookie(Config::SC_COOKIES, mech)

# Get page
wiki_page = mech.get(sc_wiki_url)

# Add hook to dump request data before sending it
mech.pre_connect_hooks << lambda do | mech2, request |
	logger.debug(URI.unescape(request.body.to_s).split("&"))
end

# Get form
wiki_form = SenscritiqueUtils.get_form_from_mechanize_page(wiki_page)

exit 1 if wiki_form == nil

need_submitting = false

# Fill in international date
if sc_international_release_date != nil && imdb_international_release_date != nil
	if sc_international_release_date != imdb_international_release_date
		wiki_form['newParameters[248][0][day]'] = imdb_international_release_date.day
		wiki_form['newParameters[248][0][month]'] = imdb_international_release_date.month
		wiki_form['newParameters[248][0][year]'] = imdb_international_release_date.year
		need_submitting = true
		logger.info("International release date set to : #{imdb_international_release_date}")
	end
end

# Fill in french date
if sc_french_release_date != nil && imdb_french_release_date != nil
	if sc_french_release_date != imdb_french_release_date
		wiki_form['newParameters[7][0][day]'] = imdb_french_release_date.day
		wiki_form['newParameters[7][0][month]'] = imdb_french_release_date.month
		wiki_form['newParameters[7][0][year]'] = imdb_french_release_date.year
		need_submitting = true
		logger.info("French release date set to : #{imdb_international_release_date}")
	end
end

logger.debug("wiki_form.inspect = #{wiki_form.inspect}")

# Skip form upload, even in debug mode
exit 0 if Config::SKIP_FORM_UPLOAD

# Submit form
if need_submitting
	logger.info("Submitting edits ...")
	mech.submit(wiki_form, wiki_form.buttons.first)
	# There is no way to check if request succeeded or not.
	# Senscritique returns an HTTP 302 redirecting to the movie's main page, whether the edit was successful or not ...
	logger.info("All edits submitted !")
else
	logger.info("No edits to make")
end