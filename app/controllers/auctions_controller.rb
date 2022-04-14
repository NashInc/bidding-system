class AuctionsController < ApplicationController
  before_action :set_auction, only: %i[show edit update destroy]
  EXCEPTIONS = [Faraday::BadRequestError, Faraday::ResourceNotFound, Faraday::ServerError,
                Faraday::ConnectionFailed, Faraday::UnauthorizedError].freeze
  # GET /auctions or /auctions.json
  def index
    @auctions = Auction.all
    auctions_response = []
    @auctions.each do |auction|
      auctions_response << auction.builder
    end
    render json: auctions_response
  end

  # GET /auctions/1 or /auctions/1.json
  def show
    customer_invoices = []

    @auction.invoices.each do |invoice|
      customer_invoices << invoice.attributes.merge(customer_name: invoice.customer.name,
                                                    phone_number: invoice.customer.phone_number)
    end
    render json: @auction.attributes.merge(collected: @auction.invoices.where(paid: true).sum(:amount),
                                           invoices: customer_invoices)
  end

  # GET /auctions/new
  def new
    @auction = Auction.new
  end

  # GET /auctions/1/edit
  def edit; end

  # POST /auctions or /auctions.json
  def create
    @auction = Auction.new(auction_params)

    respond_to do |format|
      if @auction.save
        format.html { redirect_to auction_url(@auction), notice: 'Auction was successfully created.' }
        format.json { render :show, status: :created, location: @auction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /auctions/1 or /auctions/1.json
  def update
    respond_to do |format|
      if @auction.update(auction_params)
        format.html { redirect_to auction_url(@auction), notice: 'Auction was successfully updated.' }
        format.json { render :show, status: :ok, location: @auction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auctions/1 or /auctions/1.json
  def destroy
    @auction.destroy

    respond_to do |format|
      format.html { redirect_to auctions_url, notice: 'Auction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def send_stk_push
    @api = TreasuryApi.new

    @auction = Auction.find(params['auction_id'])

    @item = @auction.item
    @item = @api.get("Items/#{@item.item_id}")
    # Create or Update an Invoice
    # split_phone = params['phone_number'][3..-1] || params['phone_number']
    split_phone = params['phone_number'].split(//).last(9).join
    # raise 'Invalid Phone Number' if split_phone.length != 9
    raise StandardError, 'Invalid Phone Number' if split_phone.length != 9

    split_phone = "254#{split_phone}"
    customers = Customer.get_customers_from_treasury ENV['business_id']

    @customer = customers.find { |customer| customer['phone_no'] == split_phone }

    @customer = Customer.post_customer_to_treasury(split_phone) if @customer.nil?

    customer = Customer.find_or_initialize_by(phone_number: @customer['phone_no'])
    customer.attributes = {
      customer_id: @customer['id']
    }
    customer.save
    # End Create or Update Invoice

    @invoice = Invoice.post_invoice_to_treasury(@item, @customer)

    # @auction = Auction.find_by(item_name: @item['name'])

    invoice = Invoice.create({
                               invoice_id: @invoice['id'],
                               customer_id: customer.id,
                               invoice_number: @invoice['invoiceNo'],
                               amount: @invoice['amount'],
                               auction_id: @auction.id,
                               bid_amount: params['bid_amount']
                             })

    accounts = Invoice.get_collection_accounts(@invoice) if @invoice

    collection_account = accounts.first['id']
    return if @invoice.nil?

    Invoice.initiate_payment(@invoice, @customer, collection_account)
  rescue *EXCEPTIONS => e
    puts e.response[:status]
    puts e.response[:header]
    puts e.response[:body]
    render json: {
      message: e.message
    }, status: e.response[:status]
  rescue StandardError => e
    render json: {
      message: e.message
    }, status: 400
  else
    # Create or Update an Item
    render json: { message: 'push sent to customer' }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_auction
    @auction = Auction.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def auction_params
    params.require(:auction).permit(:start, :end, :target, :item_id, :item_name, :customer_id, :invoice_ids)
  end
end
