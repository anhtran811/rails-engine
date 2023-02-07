class Api::V1::MerchantsController < ApplicationController
  def index
    render json: Merchant.all
  end

  def show
    if Merchant.exists?(params[:id])
      render json: Merchant.find(params[:id])
    else
      render json: { errors: "merchant does not exist" }, status: 404
    end
  end
end