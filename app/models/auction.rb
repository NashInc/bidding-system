class Auction < ApplicationRecord
  has_many :invoices
  belongs_to :item

  def builder
    attributes.merge(item: item&.builder, paybill: ENV["paybill"])
  end

  def winner
    invoices = self.invoices.where(paid: true)

    invoice_bid_amounts = []
    # from list get count
    invoices.each do |invoice|
      invoice_bid_amounts << invoice.bid_amount
    end

    central = median(invoice_bid_amounts)

    if @invoice = invoices.find { |invoice| invoice.bid_amount == central }
      self.attributes = {
        customer_id: @invoice.customer_id
      }
      save
      self
    else
      puts 'workin'

    end
    # test = invoices.group(:bid_amount).select('count(bid_amount) as count ,[bid_amount],[id]')
    # @line_items = invoices.all(:group  => "bid_amount",:select => "bid_amount, COUNT(*) as count")
    #   invoices(:group => "bid_amount", :select => "id")
    # byebug
    # grouped = invoices.group(:bid_amount).order('count_bid_amount').count('bid_amount')
    # puts grouped
    # # invoices.find { |_invoice| customer['phone_no'] == params['from'] }
  end

  def median(array)
    return nil if array.empty?

    sorted = array.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end
end
