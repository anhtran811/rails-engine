class Api::V1::Items::SearchController < ApplicationController
  def show
    if params[:name]
      if Item.search_by_name(params[:name]).nil?
        render json: { data: {} }
      else
        render json: ItemSerializer.new(Item.search_by_name(params[:name]))
      end
    elsif params[:min_price]
      if Item.search_by_price(params[:min_price], nil)
        render json: ItemSerializer.new(Item.search_by_price(params[:min_price], nil))
      end
    elsif params[:max_price]
      if Item.search_by_price(nil, params[:max_price])
        render json: ItemSerializer.new(Item.search_by_price(nil, params[:max_price]))
      end
    end
  end
end