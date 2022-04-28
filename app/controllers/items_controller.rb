# frozen_string_literal: true

# This contrller deals with Bid Items
class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  # GET /items or /items.json
  def index
    Item.get_items_from_treasury ENV['business_id']
    @items = Item.all
    items_response = []
    @items.each do |item|
      items_response << item.builder
    end
    render json: items_response.reverse
  end

  # GET /items/1 or /items/1.json
  def show; end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit; end

  # POST /items or /items.json
  def create
    @item = Item.new(item_params)

    Item.post_item_to_treasury(item_params[:name], item_params[:price], item_params[:description])
  rescue StandardError => e
    render json: {
      error: e
    }, status: 400
  else
    if @item.save
      render json: {
        success: true,
        message: 'Item Saved successfully'
      }
    else
      render json: {
        error: e
      }, status: 400
    end
  end

  # PATCH/PUT /items/1 or /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to item_url(@item), notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1 or /items/1.json
  def destroy
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def item_params
    params.permit(:name, :price, :description, :image)
  end
end
