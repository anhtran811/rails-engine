class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    if Item.exists?(params[:id])
      render json: ItemSerializer.new(Item.find(params[:id]))
    else
      render json: { errors: 'item does not exist' }, status: 404
    end
  end

  def create
    item = Item.create(item_params)
    if item.save
      render json: ItemSerializer.new(Item.create!(item_params)), status: :created
    else
      render json: { errors: "item was not created" }, status: 400
    end
  end

  def update
    item = Item.find(params[:id])
    if item.update(item_params)
      render json: ItemSerializer.new(Item.update(item_params))
    else
      render json: { errors: "item was not updated "}, status: 404
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :merchant_id, :unit_price)
  end
end