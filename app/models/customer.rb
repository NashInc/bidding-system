# frozen_string_literal: true

# This model deals with bidding system Customers/Players
class Customer < ApplicationRecord
  @api = TreasuryApi.new
  # Create a customer in treasury
  def self.post_customer_to_treasury(phone_number, name = nil)
    name = Faker::Name.unique.name if name.nil?
    params = {
      "business_id": ENV['business_id'],
      "first_name": name.split.first,
      "last_name": name.split.last,
      "email": Faker::Internet.unique.email,
      "website": 'string',
      "phone_no": phone_number,
      "address": 'string',
      "city": 'Nairobi',
      "country_id": ENV['country_id'],
      "region_name": 'Kenya'
    }
    @response = @api.post('Customers', params)
  end

  def self.get_customers_from_treasury(business_id)
    page = 1

    @response = []

    loop do
      response = @api.business_customers(business_id, page)
      @response += response['results']
      break if response['current_page'] == response['page_count']

      page += 1
    end
    @response
  end

  def self.send_message_to_customer(message, customer)
    sms = AT.sms

    options = {
      'message' => message,
      'to' => customer.to_s,
      'from' => ENV['short_code'].to_s
    }
    sms.send options
  end
end
