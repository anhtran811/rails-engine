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

        expect(items[:data].count).to eq(15)

        items[:data].each do |item|
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

    context 'when there are no items in the database' do
      it 'returns an empty array' do
        get '/api/v1/items'

        expect(response).to be_successful

        items = JSON.parse(response.body, symbolize_names: true)

        expect(items[:data]).to be_an(Array)
        expect(items[:data].count).to eq(0)
        expect(items[:data]).to eq([])
      end
    end
  end

  describe 'GET /items/:id' do
    context 'when the item exists' do
      it 'can get one item by its id' do
        item = create(:item)

        get "/api/v1/items/#{item.id}"

        item_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful

        expect(item_data).to have_key(:data)
        expect(item_data[:data]).to have_key(:attributes)

        expect(item_data[:data][:attributes]).to have_key(:name)
        expect(item_data[:data][:attributes][:name]).to be_a(String)

        expect(item_data[:data][:attributes]).to have_key(:description)
        expect(item_data[:data][:attributes][:description]).to be_a(String)

        expect(item_data[:data][:attributes]).to have_key(:unit_price)
        expect(item_data[:data][:attributes][:unit_price]).to be_a(Float)

        expect(item_data[:data][:attributes]).to have_key(:merchant_id)
        expect(item_data[:data][:attributes][:merchant_id]).to be_a(Integer)
      end
    end

    context 'when the item does not exist' do
      it 'responds with an error' do
        get "/api/v1/items/1"

        expect(response).to_not be_successful
        
        item = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(404)
        expect(item).to have_key(:error)
        # expect(item[:errors]).to match(/item does not exist/)
        expect(item[:error]).to match(/Couldn't find Item with 'id'=1/)
      end
    end
  end

  describe 'POST /items' do
    context 'when it successfully creates a new item' do
      it 'can create a new item' do
        merchant = create(:merchant)
        item_params= ({
                      name: 'Apple MacBook Pro',
                      description: 'laptop with 15in screen',
                      merchant_id: merchant.id,
                      unit_price: 1500.00
                    })
        headers = {"CONTENT_TYPE" => "application/json" }

        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
        new_item = Item.last
        
        expect(response).to be_successful
        expect(response.status).to eq(201)
        expect(new_item.name).to eq(item_params[:name])
        expect(new_item.description).to eq(item_params[:description])
        expect(new_item.merchant_id).to eq(item_params[:merchant_id])
        expect(new_item.unit_price).to eq(item_params[:unit_price])
      end

      context 'when a new item is not created' do
        it 'fails to create an item when unit price is not valid' do
          merchant = create(:merchant)
          item_params= ({
            name: 'Apple MacBook Pro',
            description: 'laptop with 15in screen',
            merchant_id: merchant.id,
            unit_price: ""
          })
          headers = { "CONTENT_TYPE" => "application/json" }

          post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
          response_body = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not be_successful
          expect(response.status).to eq(400)
    
          expect(response_body[:errors]).to_not eq(/item was not updated/)
        end
        
        it 'fails to create an item when name is left empty' do
          merchant = create(:merchant)
          item_params= ({
            name: '',
            description: 'laptop with 15in screen',
            merchant_id: merchant.id,
            unit_price: 1500.00
          })
          headers = { "CONTENT_TYPE" => "application/json" }

          post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
          response_body = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not be_successful
          expect(response.status).to eq(400)
          expect(response_body[:errors]).to_not eq(/item was not updated/)
        end

        it 'fails to create an item when desciption is left empty' do
          merchant = create(:merchant)
          item_params= ({
            name: 'Apple MacBook Pro',
            description: '',
            merchant_id: merchant.id,
            unit_price: 1500.00
            })
            headers = { "CONTENT_TYPE" => "application/json" }
            
            post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
            response_body = JSON.parse(response.body, symbolize_names: true)
            
            expect(response).to_not be_successful
            expect(response.status).to eq(400)
            expect(response_body[:errors]).to_not eq(/item was not updated/)
          end
          
        it 'fails to create an item when the merchant id is incorrect' do
          merchant = create(:merchant)
          item_params= ({
            name: 'Apple MacBook Pro',
            description: 'laptop with 15in screen',
            merchant_id: merchant.id+1,
            unit_price: 1500.00
          })
          headers = { "CONTENT_TYPE" => "application/json" }

          post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
          response_body = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not be_successful
          expect(response.status).to eq(400)
          expect(response_body[:errors]).to_not eq(/item was not updated/)
        end
      end
    end

    describe 'PATCH /items/:id' do
      context 'if the item is successfully updated' do
        it 'updates the item' do
          item = create(:item)
          previous_item_name = Item.last.name
          item_params = { name: "Apple MacBook Pro" }
          headers = { "CONTENT_TYPE" => "application/json" }

          patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
          response_body = JSON.parse(response.body, symbolize_names: true)
          item = Item.find_by(id: item.id)

          expect(response).to be_successful
          expect(item.name).to eq("Apple MacBook Pro")
          expect(item.name).to_not eq(previous_item_name)
          expect(response_body[:errors]).to_not eq(/item was not updated/)
        end
      end
      
      context 'if the item is not updated successfully' do
        it 'fails if to update if item name is left blank' do
          item = create(:item)
          previous_item_name = Item.last.name
          item_params = { name: "" }
          headers = { "CONTENT_TYPE" => "application/json" }
          
          patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
          response_body = JSON.parse(response.body, symbolize_names: true)
          item = Item.find_by(id: item.id)
          
          expect(response).to_not be_successful
          expect(response.status).to eq(404)
          expect(item.name).to eq(previous_item_name)
          expect(item.name).to_not eq("Apple MacBook Pro")
          expect(response_body[:errors]).to_not eq(/item was not updated/)
        end

        it 'fails if to update if item description is left blank' do
          item = create(:item)
          previous_item_description = Item.last.description
          item_params = { description: "" }
          headers = { "CONTENT_TYPE" => "application/json" }
          
          patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
          response_body = JSON.parse(response.body, symbolize_names: true)
          item = Item.find_by(id: item.id)
          
          expect(response).to_not be_successful
          expect(response.status).to eq(404)
          expect(item.description).to eq(previous_item_description)
          expect(item.description).to_not eq("Apple MacBook Pro")
          expect(response_body[:errors]).to_not eq(/item was not updated/)
        end

        it 'fails if to update if item unit price is not a number' do
          item = create(:item)
          previous_item_unit_price = Item.last.unit_price
          item_params = { unit_price: "number" }
          headers = { "CONTENT_TYPE" => "application/json" }
          
          patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
          response_body = JSON.parse(response.body, symbolize_names: true)
          item = Item.find_by(id: item.id)
          
          expect(response).to_not be_successful
          expect(response.status).to eq(404)
          expect(item.unit_price).to eq(previous_item_unit_price)
          expect(item.unit_price).to_not eq("Apple MacBook Pro")
          expect(response_body[:errors]).to_not eq(/item was not updated/)
        end
      end
    end
  end
end