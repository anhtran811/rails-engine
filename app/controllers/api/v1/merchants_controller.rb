class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    if params[:item_id]
      item = Item.find(params[:item_id])
      merchant = item.merchant
    else
      merchant = Merchant.find(params[:id])
    end
    render json: MerchantSerializer.new(merchant)
  end
end
# if Merchant.exists?(params[:id])
# render json: MerchantSerializer.new(Merchant.find(params[:id]))
# else
#   render json: { errors: "merchant does not exist" }, status: 404
# end