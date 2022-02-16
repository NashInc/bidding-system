# frozen_string_literal: true

class Session
  require 'uri'
  require 'net/http'

  # GET treasury token
  def self.token
    url = URI('http://identity.nashglobal.co/connect/token')

    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request.body = 'client_id=Auction&client_secret=Auction&grant_type=client_credentials&scope=NashTreasuryAPI'

    response = http.request(request)
    puts response.read_body
  rescue StandardError => e
    puts "Exception in getting Token: #{e}"
  else
    @response_json = JSON.parse(response.read_body)
    @response_json['access_token']
  end
end
