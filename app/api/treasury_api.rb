# frozen_string_literal: true

# This class deals with treasury APIs
class TreasuryApi
  attr_reader :response

  TREASURY_ENDPOINT = 'http://coreapi.nashglobal.co/api'

  def initialize; end

  def business_customers(business_id, page = nil)
    request(
      http_method: :get,
      endpoint: "Customers/Business/#{business_id}?page=#{page}"
    )
  end

  def business_items(business_id, page = nil)
    request(
      http_method: :get,
      endpoint: "Customers/Business/#{business_id}?page=#{page}"
    )
  end

  def get(url, business_id = nil, page = nil)
    request(
      http_method: :get,
      endpoint: "#{url}?businessId=#{business_id}&page=#{page}"
    )
  end

  def post(url, body)
    puts 'Request Body:: '
    puts body.to_json
    request(
      http_method: :post,
      endpoint: url.to_s,
      body: body.to_json
    )
  end

  def send_message(body)
    request(
      http_method: :post,
      endpoint: 'Notifications/Sms',
      body: body.to_json
    )
  end

  def base_client
    @base_client ||= Faraday.new(TREASURY_ENDPOINT) do |base_client|
      base_client.adapter Faraday.default_adapter
      base_client.headers['Authorization'] = "Bearer #{Session.token}"
      base_client.headers['Content-Type'] = 'application/json'
      base_client.use Faraday::Response::RaiseError
    end
  end

  def request(http_method:, endpoint:, body: {})
    @response = base_client.public_send(http_method, endpoint, body)
    puts 'Treasury Response ::'
    puts @response.body
    JSON.parse(@response.body) if response_successful?
  end

  private

  def response_successful?
    return true if @response.success?

    false
  end
end
