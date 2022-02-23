# frozen_string_literal: true

# This class deals with Invoice Configuration
class Invoice < ApplicationRecord
  belongs_to :auction, optional: true
  belongs_to :customer, optional: true

  @api = TreasuryApi.new

  # create an Invoice in Treasury
  def self.post_invoice_to_treasury(item, customer)
    params = {
      "invoice_header": 'Invoice for Auction',
      "description": 'Invoice for Auction',
      "currency_id": ENV['currency_id'],
      "notes": "Invoice for Bid #{item['name']}",
      "is_completed": true,
      "require_approval": false,
      "invoice_model_details": [
        {
          "item_id": item['id'],
          "quantity": 1,
          "price": item['price'],
          "submitted_currency": ENV['currency_id'],
          "exchange_rate": 1
        }
      ],
      "invoice_destination_accounts": [
        {
          "invoice_account_type": 'LinkedAccount',
          "account_no": ENV['business_bank_id']
        }
      ]
    }
    @response = @api.post("Customers/#{customer['id']}/CreateInvoice", params)
  end

  # Initiates Payment of an Invoice on Treasury
  def self.initiate_payment(invoice, customer, collection_account)
    params = {
      "currency_code": ENV['currency_code'],
      "amount": invoice['amount'],
      "payment_mode": 'MobileMoney',
      "sender_bank_id": ENV['mpesa_id'],
      "sender_account": customer['phone_no'],
      "invoice_account_id": collection_account
    }
    @response = @api.post("Invoices/#{invoice['id']}/InitiatePayment", params)
  end

  def self.get_collection_accounts(invoice)
    @response = @api.get("Invoices/#{invoice['id']}/GetCollectionAccounts")
  end

  def self.get_invoice(id)
    @invoice = @api.get("Invoices/#{id}")
  end
end
