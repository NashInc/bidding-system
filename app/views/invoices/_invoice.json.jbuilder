json.extract! invoice, :id, :invoice_number, :amount, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
