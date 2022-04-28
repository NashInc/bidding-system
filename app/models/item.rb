class Item < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :image
  has_many :auction

  def image_url
    return nil unless image.attached?

    url_for(image)
  end

  def builder
    attributes.merge(image: image_url)
  end

  @api = TreasuryApi.new

  def self.update_item_on_treasury(id, name, price, description)
    @api.put("Items/#{id}", Item.item_body(name, price, description))
  end

  def self.delete_item_on_treasury(id)
    @api.delete("Items/#{id}")
  end

  # This method creates an Item on treasury
  def self.post_item_to_treasury(name, price, description)
    @api.post('Items', Item.item_body(name, price, description))
  end

  def self.get_items_from_treasury(business_id)
    page = 1

    @response = []

    loop do
      response = @api.get('Items', business_id, page)
      @response += response['results']
      break if response['page_count'] == 0
      break if response['current_page'] == response['page_count']

      page += 1
    end

    @response.each do |item|
      @item = Item.find_or_initialize_by(item_id: item['id'])
      @item.attributes = {
        name: item['name'],
        price: item['price'],
        description: item['description']
      }
      @item.save!
    end

    @response
  end

  def self.item_body(name, price, description)
    {
      "Name": name.to_s,
      "BusinessId": ENV['business_id'],
      "Price": price.to_i,
      "Quantity": 99_999,
      "ItemProductType": 'Inventory',
      "IncludeInInvoice": true,
      "IncludeInBill": true,
      "CurrencyId": ENV['currency_id'],
      "Description": description.to_s
    }
  end
end
