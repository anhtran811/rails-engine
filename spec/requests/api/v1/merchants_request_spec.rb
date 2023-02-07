require 'rails_helper' 

describe 'Merchants API' do
  describe 'GET /merchants' do
    context 'when merchants exist' do
      it 'sends a list of merchants' do
        create_list(:merchant, 5)

        get '/api/v1/merchants'
        
        expect(response).to be_successful
        
        merchants = JSON.parse(response.body, symbolize_names: true)
        
        expect(merchants.count).to eq(5)
        
        merchants.each do |merchant|
          expect(merchant).to have_key(:id)
          expect(merchant[:id]).to be_an(Integer)
          
          expect(merchant).to have_key(:name)
          expect(merchant[:name]).to be_an(String)
        end
      end
    end
      
    context 'when there are no merchants in the database' do
      it 'returns an empty array' do
        get '/api/v1/merchants'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants).to be_an(Array)
        expect(merchants.count).to eq(0)        
        expect(merchants).to eq([])        
      end
    end
  end
    
  describe 'GET merchants/:id' do
    context 'when the merchant exists' do
      it 'can get one merchant by their id' do
        id = create(:merchant).id

        get "/api/v1/merchants/#{id}"

        merchant = JSON.parse(response.body, symbolize_names: true)
        
        expect(response).to be_successful

        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(Integer)
        
        expect(merchant).to have_key(:name)
        expect(merchant[:name]).to be_a(String)
      end
    end
    
    context 'when the merchant does not exist' do
      it 'responds with an error' do
        get "/api/v1/merchants/1"
        
        merchant = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to eq(404)
        expect(merchant).to have_key(:errors)
        expect(merchant[:errors]).to match(/merchant does not exist/)
      end
    end
  end

  describe 'GET /merchants/:id/items' do
    context 'when the merchant exists' do
      it 'sends a list of all items for that merchant' do
        merchant = create(:merchant)
        items = create_list(:item, 10, merchant_id: merchant.id)

        get "/api/v1/merchants/#{merchant.id}/items"

        items_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        
        items_data.each do |item|
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
    
    context 'when the merchant does not exist' do
      it 'responds with an error' do
        get "/api/v1/merchants/1/items"

        items_data = JSON.parse(response.body, symbolize_names: true)
        expect(response.status).to eq(404)
        expect(items_data).to have_key(:errors)
        expect(items_data[:errors]).to match(/merchant item does not exist/)
      end
    end
  end
end