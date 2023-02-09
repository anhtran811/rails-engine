require 'rails_helper' 

describe 'Merchants API' do
  describe 'GET /merchants' do
    context 'when merchants exist' do
      it 'sends a list of merchants' do
        create_list(:merchant, 5)

        get '/api/v1/merchants'
        
        expect(response).to be_successful
        
        merchants = JSON.parse(response.body, symbolize_names: true)
        
        expect(merchants[:data].count).to eq(5)
        
        merchants[:data].each do |merchant|
          expect(merchant).to have_key(:id)
          expect(merchant[:id]).to be_a(String)
          
          expect(merchant[:attributes]).to have_key(:name)
          expect(merchant[:attributes][:name]).to be_a(String)
        end
      end
    end
      
    context 'when there are no merchants in the database' do
      it 'returns an empty array' do
        get '/api/v1/merchants'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].count).to eq(0)        
        expect(merchants[:data]).to be_an(Array)
        expect(merchants[:data]).to eq([])        
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

        expect(merchant).to have_key(:data)
        expect(merchant[:data]).to have_key(:attributes)
  
        expect(merchant[:data][:id]).to be_a(String)
        
        expect(merchant[:data][:attributes]).to have_key(:name)
        expect(merchant[:data][:attributes][:name]).to be_a(String)
      end
    end
    
    context 'when the merchant does not exist' do
      it 'responds with an error' do
        merchant = create(:merchant)

        get "/api/v1/merchants/#{Merchant.last.id+1}"
        
        expect(response).to_not be_successful

        merchant = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(404)
        expect(merchant).to have_key(:error)
        expect(merchant[:error]).to match(/Couldn't find Merchant with 'id'=#{Merchant.last.id+1}/)
      end
    end
  end

  describe 'find all merchants by name' do
    context 'if merchant is found' do
      it 'returns a collection of merchants, by name in case-insensitive alphabetical order' do
        merchant_1 = create(:merchant, name: "Harry Potter")
        merchant_2 = create(:merchant, name: "Hermione Granger")
        merchant_3 = create(:merchant, name: "Ronald Weasley")
        merchant_4 = create(:merchant, name: "Severus Snape")
      
        get '/api/v1/merchants/find_all?name=er'

        merchants_data = JSON.parse(response.body, symbolize_names: true)
        expect(response).to be_successful
        expect(merchants_data).to have_key(:data)
        expect(merchants_data[:data].count).to eq(3)
       
        merchants_data[:data].each do |merchant|
          expect(merchant).to have_key(:attributes)
          expect(merchant[:attributes]).to have_key(:name)
          expect(merchant[:attributes][:name]).to be_a(String)
        end
      end
    end

    context 'if the merchant is not found' do
      it 'it will return a hash if parameters does not match a merchant' do
        merchant_1 = create(:merchant)

        get "/api/v1/merchants/find_all?name=person"

        merchant_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(merchant_data).to have_key(:data)
        expect(merchant_data).to be_a(Hash)
      end
    end
  end
end