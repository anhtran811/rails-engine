class Api::V1::Items::SearchController < ApplicationController
  def show
    item = Item.search_by_name(params[:name])
    if item == nil
      render json: { data: {} }
    else
      render json: ItemSerializer.new(item)
    end
  end
end