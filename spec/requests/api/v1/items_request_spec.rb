require 'rails_helper'

describe 'Items API' do
  describe 'GET /items' do
    context 'when items exist' do
      it 'sends a list of items' do
        merchant_1 = create(:merchant)
        merchant_2 = create(:merchant)
        items_1 = create_list(:item, 10, merchant_id: merchant_1.id)
        items_2 = create_list(:item, 5, merchant_id: merchant_2.id)

        get '/api/v1/items'

        expect(response).to be_successful
    
        items = JSON.parse(response.body, symbolize_names: true)

        expect(items.count).to eq(15)

        items.each do |item|
          expect(item).to have_key(:id)
          expect(item[:id]).to be_a(Integer)
          
          expect(item).to have_key(:name)
          expect(item[:name]).to be_a(String)

          expect(item).to have_key(:description)
          expect(item[:description]).to be_a(String)

          expect(item).to have_key(:unit_price)
          expect(item[:unit_price]).to be_a(Float)

          expect(item).to have_key(:merchant_id)
          expect(item[:merchant_id]).to be_a(Integer)
        end
      end
    end

    context 'when there are no items in the database' do
      it 'returns an empty array' do
        get '/api/v1/items'

        expect(response).to be_successful

        items = JSON.parse(response.body, symbolize_names: true)

        expect(items).to be_an(Array)
        expect(items.count).to eq(0)
        expect(items).to eq([])
      end
    end
  end
end