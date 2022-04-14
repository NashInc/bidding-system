# frozen_string_literal: true

# This model deals with bidding system Customers/Players
class Customer < ApplicationRecord
  has_many :invoices

  @api = TreasuryApi.new
  # Create a customer in treasury
  def self.post_customer_to_treasury(phone_number, name = nil)
    name = Faker::Name.unique.name if name.nil?
    params = {
      "business_id": ENV['business_id'],
      "first_name": name.split.first,
      "last_name": name.split.last,
      "customer_business_name": name,
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

  # GET CUSTOMERS FROM TREASURY
  def self.get_customers_from_treasury(business_id)
    page = 1

    @response = []

    loop do
      response = @api.business_customers(business_id, page)
      @response += response['results']
      break if response['page_count'] == 0
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

    # body = {
    #   message: message,
    #   recipients: [customer.to_s]
    # }
    # @api.send_message(body)
  end

  # Update customer

  def self.update_customer_on_treasury(bidding_customer)
    name = bidding_customer.name
    params = {
      "business_id": ENV['business_id'],
      "first_name": name.split.first,
      "last_name": name.split.last,
      "customer_business_name": name,
      "email": Faker::Internet.unique.email,
      "website": 'string',
      "phone_no": bidding_customer.phone_number,
      "address": 'string',
      "city": 'Nairobi',
      "country_id": ENV['country_id'],
      "region_name": 'Kenya'
    }
    @response = @api.put("Customers/#{bidding_customer.customer_id}", params)
  end
end
