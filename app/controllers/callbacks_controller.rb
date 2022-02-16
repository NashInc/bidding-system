class CallbacksController < ApplicationController
  def test; end

  EXCEPTIONS = [Faraday::BadRequestError, Faraday::ResourceNotFound].freeze

  def fetch_subscriptions
    sms = AT.sms
    # Set your premium product shortCode and keyword
    short_code = '2111'
    keyword = '2111'

    last_received_id = 0

    loop do
      options = {
        'shortCode' => short_code,
        'keyword' => keyword,
        'lastReceivedId' => last_received_id
      }

      subscribers = sms.fetchSubscriptions options

      subscribers.each do |subscriber|
        puts subscriber.to_yaml
      end

      # Reassign the lastReceivedId
      break if subscribers.length < 1

      last_received_id = subscribers.last.id

    # NOTE: Be sure to save the lastReceivedId for next time
    rescue AfricasTalking::AfricasTalkingException => e
      puts "Encountered an error: #{e.message}"
    else
    end
  end

  def inbox
    inbox_json = {
      id: params['id'],
      linkId: params['linkId'],
      text: params['text'],
      to: params['to'],
      date: params['date'],
      from: params['from']
    }
    puts inbox_json
    # find or create customer
    customers = Customer.get_customers_from_treasury ENV['business_id']

    @customer = customers.find { |customer| customer['phone_no'] == params['from'] }

    @customer = Customer.post_customer_to_treasury(params['from']) if @customer.nil?
    # match text to an item

    

    # If text is okay
    # create payment link
    # send stk push
    # else
    # send customer text with instructions

    # CUSTOMER
    # {
    #   "business_id": '017efc9a-dd56-4b2f-abdb-9b18394c132e',
    #   "customer_business_name": 'string',
    #   "first_name": 'string',
    #   "last_name": 'string',
    #   "email": 'string', # not null
    #   "website": 'string',
    #   "phone_no": 'string',
    #   "address": 'string',
    #   "city": 'string',
    #   "country_id": 'd66bb4d3-dad5-4283-a5c0-9dadc1bc209f',
    #   "region_name": 'string'
    # }

    # Link account json
    # {
    #   "bank_id": '3fa85f64-5717-4562-b3fc-2c963f66afa6',
    #   "bank_account_number": '4074785',
    #   "bank_account_name": 'Nash Finanicial',

    #   "bank_account_type": 'Collection'
    # }
  rescue *EXCEPTIONS => e
    puts e.response[:status]
    puts e.response[:header]
    puts e.response[:body]
  end
end
