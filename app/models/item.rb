class Item < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :image

  def image_url
    return nil unless image.attached?

    url_for(image)
  end

  def builder
    attributes.merge(image: image_url)
  end

  @api = TreasuryApi.new
  def self.post_item_to_treasury
    {
      "Name": 'string',
      "BusinessId": '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      "Price": 0,
      "Quantity": 0,
      "IncludeInInvoice": true,
      "IncludeInBill": 0,
      "CurrencyId": '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      "Description": 'string'
    }
  end

  def self.get_items_from_treasury(business_id)
    page = 1

    @response = []

    loop do
      response = @api.get('Items', business_id, page)
      @response += response['results']
      break if response['current_page'] == response['page_count']

      page += 1
    end
    @response
  end
end
