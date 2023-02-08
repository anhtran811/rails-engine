require 'rails_helper'

describe 'GET /merchants/:id/items' do
  context 'when the merchant exists' do
    it 'sends a list of all items for that merchant' do
      merchant = create(:merchant)
      items = create_list(:item, 10, merchant_id: merchant.id)

      get "/api/v1/merchants/#{merchant.id}/items"

      items_data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(items_data.count).to eq(10)

      expect(response).to be_successful
      items_data.each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_a(String)

        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to be_a(String)

        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to be_a(String)


        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to be_a(Float)

        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to be_a(Integer)
      end
    end
  end
  
  context 'when the merchant does not exist' do
    it 'responds with an error' do
      # merchant = create(:merchant)
      items = create_list(:item, 10)
      get "/api/v1/merchants/1/items"

      items_data = JSON.parse(response.body, symbolize_names: true)
      expect(response.status).to eq(404)
      expect(items_data).to have_key(:error)
      expect(items_data[:error]).to match(/Couldn't find Merchant with 'id'=1/)
    end
  end
end