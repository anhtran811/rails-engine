class Api::V1::Items::SearchController < ApplicationController
  def show
    if (params[:name] && (params[:min_price] || params[:max_price]))
      render json: ErrorSerializer.invalid_parameters("cannot send name with price"), status: 400
    elsif params[:min_price] || params[:max_price]
        by_price
    elsif params[:name]
      by_name
    else 
       by_invalid_search
    end
  end

  private

  def by_invalid_search
    if params[:name] == ""
      render json: { data: { errors: "parameter cannot be empty" } }, status: 400
    else
      render json: { data: { errors: "parameter cannot be missing" } }, status: 400
    end
  end

  def by_name 
    if Item.search_by_name(params[:name]).nil?
      render json: ErrorSerializer.invalid_parameters("parameter cannot be empty")
    else
      render json: ItemSerializer.new(Item.search_by_name(params[:name]))
    end
  end

  def by_price 
    if (params[:min_price].to_f < 0) || (params[:max_price].to_f < 0)
      result = ErrorSerializer.bad_request("price cannot be less than zero")
      status = 400
    else
      items =  Item.search_by_price(params[:min_price], params[:max_price])
      result = ItemSerializer.new(items)
      if items.nil?
        result = ErrorSerializer.no_matches_found
      end
    end
    render json: result, status: status
  end
end
