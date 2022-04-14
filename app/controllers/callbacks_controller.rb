# frozen_string_literal: true

# This controller receives callbacks from External Systems
class CallbacksController < ApplicationController
  def test; end

  EXCEPTIONS = [Faraday::BadRequestError, Faraday::ResourceNotFound, Faraday::ServerError,
                Faraday::ConnectionFailed, Faraday::UnauthorizedError].freeze

  # Receives Treasury Payment Callbacks for MPESA transactions
  def treasury_payment_callback
    @api = TreasuryApi.new
    {
      "account_to": 'string',
      "account_to_name": 'string',
      "account_from": 'string',
      "account_from_name": 'string',
      "transaction_id": 'string',
      "amount": 0,
      "account_reference": 'string',
      "identifier": 'string',
      "transaction_desc": 'string'
    }

    @invoice = Invoice.find_by(invoice_number: params['account_reference'])
    if @invoice
      @invoice.attributes = {
        paid: true
      }
      @invoice.save
      @invoice.customer.update(
        name: params['account_from_name']
      )
      Customer.update_customer_on_treasury(@invoice.customer)
      message = "Your bid for #{@invoice.auction.item.name} with amount #{@invoice.bid_amount} has been received"
      Customer.send_message_to_customer(message, params['account_from'])
    else
      # new customer stuff
      customers = Customer.get_customers_from_treasury ENV['business_id']
      # split_phsone = params['account_from'][3..-1] || params['account_from']\
      split_phone = params['account_from'].split(//).last(9).join
      split_phone = "254#{split_phone}"
      @customer = customers.find { |customer| customer['phone_no'] == split_phone }

      if @customer.nil?
        @customer = Customer.post_customer_to_treasury(split_phone,
                                                       params['account_from_name'])
      end
      # match text to an item

      customer = Customer.find_or_initialize_by(phone_number: @customer['phone_no'])
      customer.attributes = {
        customer_id: @customer['id'],
        name: params['account_from_name']
      }
      customer.save
      text_array = params['account_reference'].scan(/\d+|[A-Za-z]+/)
      name = text_array.first
      amount = text_array.last
      if @item = Item.find_by(name: name)
        @item = @api.get("Items/#{@item.item_id}")

        @invoice = Invoice.post_invoice_to_treasury(@item, @customer)

        @auction = Auction.find_by(item_name: @item['name'])

        invoice = Invoice.create({
                                   invoice_id: @invoice['id'],
                                   customer_id: customer.id,
                                   invoice_number: @invoice['invoiceNo'],
                                   amount: @invoice['amount'],
                                   auction_id: @auction ? @auction.id : nil,
                                   bid_amount: params['account_reference']
                                 })

        message = "Your bid for #{@item['name']} with amount #{params['account_reference']} has been received"
        Customer.send_message_to_customer(message, params['account_from'])

      else
        puts 'No my Payment'
      end

    end
  rescue *EXCEPTIONS => e
    puts e.response[:status]
    puts e.response[:header]
    puts e.response[:body]
  end

  # Receives ShortCode callbacks from AfricasTalking
  def inbox
    text_array = params['text'].scan(/\d+|[A-Za-z]+/)
    name = text_array.first
    amount = text_array.last
    # inbox_json = {
    #   id: params['id'],
    #   linkId: params['linkId'],
    #   text: params['text'],
    #   to: params['to'],
    #   date: params['date'],
    #   from: params['from']
    # }
    # puts inbox_json
    # find or create customer
    customers = Customer.get_customers_from_treasury ENV['business_id']
    split_phone = params['from'].split(//).last(9).join
    split_phone = "254#{split_phone}"
    @customer = customers.find { |customer| customer['phone_no'] == split_phone }

    @customer = Customer.post_customer_to_treasury(split_phone) if @customer.nil?
    # match text to an item

    customer = Customer.find_or_initialize_by(phone_number: @customer['phone_no'])
    customer.attributes = {
      customer_id: @customer['id']
    }
    customer.save

    items = Item.get_items_from_treasury ENV['business_id']

    @item = items.find { |item| item['name'].casecmp(name).zero? }

    if @item
      Customer.send_message_to_customer("Bid for #{name} received. You will receive STK push shortly",
                                        @customer['phone_no'])
    end
    return Customer.send_message_to_customer('The Item is not available for sale', @customer['phone_no']) if @item.nil?

    # create an invoice for this transaction
    @invoice = Invoice.post_invoice_to_treasury(@item, @customer)

    @auction = Auction.find_by("item_name like ?", "%#{name}%")

    invoice = Invoice.create({
                               invoice_id: @invoice['id'],
                               customer_id: customer.id,
                               invoice_number: @invoice['invoiceNo'],
                               amount: @invoice['amount'],
                               auction_id: @auction ? @auction.id : nil,
                               bid_amount: amount
                             })

    accounts = Invoice.get_collection_accounts(@invoice) if @invoice

    collection_account = accounts.first['id']
    return if @invoice.nil?

    Invoice.initiate_payment(@invoice, @customer, collection_account)
  rescue *EXCEPTIONS => e
    puts e.response[:status]
    puts e.response[:header]
    puts e.response[:body]
  rescue AfricasTalking::AfricasTalkingException => e
    puts "AT exception: #{e.message}"
  end
end
