module HttpUtils



	def self.get(url, cookies={})
		response = RestClient.get(url, {:cookies => cookies})
		return response
	end



	def self.add_sc_cookie(cookies, mechanize_instance)
		cookies.each do | key, value |
			cookie = Mechanize::Cookie.new(key, value)
			cookie.domain = ".senscritique.com"
			cookie.path = "/"
			mechanize_instance.cookie_jar.add(cookie)
		end
	end



end