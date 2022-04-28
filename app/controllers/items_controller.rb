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

    response = Item.post_item_to_treasury(item_params[:name], item_params[:price], item_params[:description])
  rescue StandardError => e
    render json: {
      error: e
    }, status: 400
  else
    @item.item_id = response['id']
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
    Item.update_item_on_treasury(@item.item_id, item_params['name'], item_params['price'], item_params['description'])
  rescue StandardError => e
    render json: {
      error: e
    }
  else
    if @item.update(item_params)
      render json: {
        success: true,
        message: 'Item updated successfully',
        data: @item
      }
    else
      render json: {
        success: false,
        error: @item.errors
      }, status: 400
    end
  end

  # DELETE /items/1 or /items/1.json
  def destroy
    Item.delete_item_on_treasury(@item.item_id)
  rescue StandardError => e
    render json: {
      error: e
    }, status: 400
  else
    @item.destroy

    render json: {
      success: true,
      message: 'Item deleted successfully'
    }, status: 200
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
