class Api::V1::Merchants::SearchController < ApplicationController
  def index
    if params[:name]
      render json: MerchantSerializer.new(Merchant.search_all_by_name(params[:name]))
    else 
      render json: ErrorSerializer.no_matches_found
    end
  end
end