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
        item = create(:item)
        get "/api/v1/items/#{Item.last.id+1}"

        expect(response).to_not be_successful
        
        item = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq(404)
        expect(item).to have_key(:error)
        # expect(item[:errors]).to match(/item does not exist/)
        expect(item[:error]).to match(/Couldn't find Item with 'id'=#{Item.last.id+1}/)
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
        expect(response_body[:errors]).to match(/item was not updated/)
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
        expect(response_body[:errors]).to match(/item was not updated/)
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
        expect(response_body[:errors]).to match(/item was not updated/)
      end
    end
  end

  describe 'DELETE /items/:id' do
    context 'when an item is successfully deleted' do
      it 'can delete an item' do
        merchant = create(:merchant)
        customer = create(:customer)

        item = create(:item, merchant_id: merchant.id)
        item_2 = create(:item, merchant_id: merchant.id)

        invoice_1 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
        invoice_2 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
        
        invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item.id, quantity: 2)
        invoice_item_2 = create(:invoice_item, invoice_id: invoice_2.id, item_id: item.id, quantity: 4)
        invoice_item_3 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_2.id, quantity: 3)
        
        expect(Item.count).to eq(2)
        expect(Invoice.count).to eq(2)
        expect(InvoiceItem.count).to eq(3)
        expect(Merchant.count).to eq(1)

        delete "/api/v1/items/#{item.id}"

        expect(response).to be_successful
        expect(response.status).to eq(204)
        expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
        expect(Item.count).to eq(1)
        expect(Invoice.count).to eq(1)
        expect(InvoiceItem.count).to eq(1)
        expect(Merchant.count).to eq(1)
      end
    end

    context 'when the item does not exist' do
      it 'sends an error message' do
        merchant = create(:merchant)
        customer = create(:customer)

        item = create(:item, merchant_id: merchant.id)
        item_2 = create(:item, merchant_id: merchant.id)

        invoice_1 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
        invoice_2 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
        
        invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item.id, quantity: 2)
        invoice_item_2 = create(:invoice_item, invoice_id: invoice_2.id, item_id: item.id, quantity: 4)
        invoice_item_3 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_2.id, quantity: 3)
        
        expect(Item.count).to eq(2)
        expect(Invoice.count).to eq(2)
        expect(InvoiceItem.count).to eq(3)
        expect(Merchant.count).to eq(1)

        delete "/api/v1/items/#{Item.last.id+1}"
        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response).to_not be_successful
        expect(response.status).to eq(404)
        expect(response_body[:error]).to match(/Couldn't find Item with 'id'=#{Item.last.id+1}/)
        expect(Item.count).to eq(2)
        expect(Invoice.count).to eq(2)
        expect(InvoiceItem.count).to eq(3)
        expect(Merchant.count).to eq(1)
      end
    end
  end

  describe 'GET /items/:id/merchant' do
    context 'when the item exists' do
      it 'returns the merchant data associated with an item' do
        merchant_1 = create(:merchant)
        merchant_2 = create(:merchant)
        item = create(:item, merchant_id: merchant_1.id)

        get "/api/v1/items/#{item.id}/merchant"

        merchant_data = JSON.parse(response.body, symbolize_names: true)
      
        expect(response).to be_successful
        expect(merchant_data).to have_key(:data)

        expect(merchant_data[:data]).to have_key(:id)
        expect(merchant_data[:data][:id]).to be_a(String)
        expect(merchant_data[:data]).to have_key(:attributes)
        expect(merchant_data[:data][:attributes]).to have_key(:name)
        expect(merchant_data[:data][:attributes][:name]).to be_a(String)
      end
    end

    context 'when the item does not exist' do
      it 'returns an errors' do
        merchant_1 = create(:merchant)
        item = create(:item, merchant_id: merchant_1.id)

        get "/api/v1/items/#{Item.last.id+1}/merchant"

        response_body = JSON.parse(response.body, symbolize_names: true)
      
        expect(response).to_not be_successful
        expect(response.status).to eq(404)
        expect(response_body[:error]).to match(/Couldn't find Item with 'id'=#{Item.last.id+1}/)
      end
    end
  end

  #non-restful search endpoints

  describe 'find one item by name' do
    context 'if item is found' do
      it 'if found, can return one single object, by name in case-insensitive alphabetical order' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", description: "This is a school", merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", description: "This is a game", merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", description: "Beautiful ring", merchant_id: merchant_1.id)

        get "/api/v1/items/find?name=ring"

        item_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(item_data).to have_key(:data)
        expect(item_data[:data]).to have_key(:id)
        
        item = item_data[:data]
        
        expect(item).to have_key(:attributes)
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to eq(item_2.name)

        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to eq(item_2.description)

        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to eq(item_2.unit_price)

        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to eq(item_2.merchant_id)
      end
    end

    context 'if the item is not found' do
      it 'will return a hash if parameters do not match items' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", description: "This is a school", merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", description: "This is a game", merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", description: "Beautiful ring", merchant_id: merchant_1.id)

        get "/api/v1/items/find?name=person"

        item_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(item_data).to have_key(:data)
        expect(item_data).to be_a(Hash)
      end
    end
  end

  describe 'find on item by price' do
    context 'if the item meets the price parameters' do
      it 'it returns the first item that is greater than or equal to the min price' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)

        get "/api/v1/items/find?min_price=150"

        item_data = JSON.parse(response.body, symbolize_names: true)
        expect(response).to be_successful

        expect(item_data).to have_key(:data)
        expect(item_data[:data]).to have_key(:id)
        
        item = item_data[:data]
        
        expect(item).to have_key(:attributes)
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to eq(item_3.name)

        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to eq(item_3.description)

        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to eq(item_3.unit_price)

        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to eq(item_3.merchant_id)
      end
      
      it 'it returns the first item that is less than or equal to the max price' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)

        get "/api/v1/items/find?max_price=550"

        item_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful

        expect(item_data).to have_key(:data)
        expect(item_data[:data]).to have_key(:id)
        
        item = item_data[:data]
        
        expect(item).to have_key(:attributes)
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to eq(item_2.name)

        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to eq(item_2.description)

        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to eq(item_2.unit_price)

        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to eq(item_2.merchant_id)
      end

      it 'it returns the first item within a price range' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)

        get "/api/v1/items/find?min_price=500&max_price=1500"

        item_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful

        expect(item_data).to have_key(:data)
        expect(item_data[:data]).to have_key(:id)
        
        item = item_data[:data]
        
        expect(item).to have_key(:attributes)
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to eq(item_3.name)

        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to eq(item_3.description)

        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to eq(item_3.unit_price)

        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to eq(item_3.merchant_id)
      end
    end

    context 'if the parameters are not met' do
      it 'returns an error if the min price parameter is too high' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)

        get "/api/v1/items/find?min_price=1500"

        item_data = JSON.parse(response.body, symbolize_names: true)
        expect(response).to be_successful
        expect(item_data).to have_key(:data)
        expect(item_data).to be_a(Hash)
      end

      it 'returns an error if the max price parameter is too low' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)
        
        get "/api/v1/items/find?max_price=50"
        
        item_data = JSON.parse(response.body, symbolize_names: true)
        
        expect(response).to be_successful
        expect(item_data).to have_key(:data)
        expect(item_data).to be_a(Hash)
      end
    end
  end

  describe 'invalid inputs' do
    it 'cannot send both name and min and/or max price as a parameter' do
      merchant_1 = create(:merchant)
      item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
      item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
      item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)
      
      get "/api/v1/items/find?name=ring&min_price=50"
      item_data = JSON.parse(response.body, symbolize_names: true)
        
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_a(Hash)
      expect(item_data[:data][:errors]).to match(/cannot send name with price/)

      get "/api/v1/items/find?name=ring&max_price=50"
      item_data = JSON.parse(response.body, symbolize_names: true)
        
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_a(Hash)
      expect(item_data[:data][:errors]).to match(/cannot send name with price/)
      
      get "/api/v1/items/find?name=ring&min_price=50&max_price=250"
      item_data = JSON.parse(response.body, symbolize_names: true)
        
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
      expect(item_data).to have_key(:data)
      expect(item_data[:data]).to be_a(Hash)
      expect(item_data[:data][:errors]).to match(/cannot send name with price/)
    end
    
    it 'cannot send a min/max price less than 0' do
      merchant_1 = create(:merchant)
      item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
      item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
      item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)
      
      get "/api/v1/items/find?min_price=-1"
      item_data = JSON.parse(response.body, symbolize_names: true)
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
      expect(item_data).to have_key(:errors)
      expect(item_data[:errors]).to be_a(String)
      expect(item_data[:errors]).to match(/price cannot be less than zero/)

      get "/api/v1/items/find?max_price=-50"
      item_data = JSON.parse(response.body, symbolize_names: true)
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
      expect(item_data).to have_key(:errors)
      expect(item_data[:errors]).to be_a(String)
      expect(item_data[:errors]).to match(/price cannot be less than zero/)
    end

    xit 'cannot have a parameter missing' do
      merchant_1 = create(:merchant)
      item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
      item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
      item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)

      get "/api/v1/items/find"
     
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(400)

      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to have_key(:errors)
      expect(response_body[:data][:errors]).to match(/parameter cannot be missing/)
    end

    xit 'cannot have an empty parameter' do
      merchant_1 = create(:merchant)
      item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
      item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
      item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)

      get "/api/v1/items/find?name="
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(400)

      expect(response_body).to have_key(:data)
      # expect(response_body[:data]).to eq({})
      expect(response_body[:data][:errors]).to match(/parameter cannot be empty/)
    end
  end
end
