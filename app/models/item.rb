class Item < ApplicationRecord
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