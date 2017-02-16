module HttpUtils



	def self.get(url, cookies={})
		response = RestClient.get(url, {:cookies => cookies})
		return response
	end



end