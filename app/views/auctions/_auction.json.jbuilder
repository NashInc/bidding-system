json.extract! auction, :id, :start, :end, :target, :item_id, :item_name, :customer_id, :invoice_ids, :created_at, :updated_at
json.url auction_url(auction, format: :json)
