class Api::V1::ItemsController < ApplicationController
  def index
    render json: Item.all
  end

  def show
    if Item.exists?(params[:id])
      render json: Item.find(params[:id])
    else
      render json: { errors: 'item does not exist' }, status: 404
    end
  end
end