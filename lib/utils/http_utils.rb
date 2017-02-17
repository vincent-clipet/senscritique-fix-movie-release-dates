module HttpUtils



	def self.get(url, cookies={}, user_agent)
		response = RestClient.get(url, {:cookies => cookies, :user_agent => user_agent})
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