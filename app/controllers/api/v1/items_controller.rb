class Api::V1::ItemsController < ApplicationController
  def index
    if Merchant.exists?(params[:merchant_id])
      render json: Item.all
    else
      render json: { errors: /merchant item does not exist/}, status: 404
    end
  end
end