require 'rails_helper' 

describe 'Merchants API' do
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
    
    context 'when there are no merchants in the database' do
      it 'returns an empty array' do
        get '/api/v1/merchants'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_name: true)

        expect(merchants).to be_an(Array)
        expect(merchants.count).to eq(0)        
      end
    end
  end
end