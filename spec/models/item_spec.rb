require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:merchant_id) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_numericality_of(:unit_price) }
  end

  describe 'class methods' do
    describe ":search_by_name" do
      it 'returns the first item by alphabetical order, with case-insensitive and partial search parameter matches' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", description: "This is a school", merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", description: "This is a game", merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", description: "Beautiful ring", merchant_id: merchant_1.id)

        expect(Item.search_by_name("ring")).to eq(item_2)
      end
    end

    describe ":search_by_price" do
      it 'returns one item that meets the min price, alphabetized' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)

        expect(Item.search_by_price(150.00, nil)).to eq(item_3)
      end

      it 'returns one item that meets the max price, alphabetized' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)

        expect(Item.search_by_price(nil, 550.00)).to eq(item_2)
      end

      it 'it returns the first item within a price range' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, name: "Turing", unit_price: 1000.00, merchant_id: merchant_1.id)
        item_2 = create(:item, name: "Ring World", unit_price: 100.00, merchant_id: merchant_1.id)
        item_3 = create(:item, name: "Titanium Ring", unit_price: 500.00, merchant_id: merchant_1.id)

        expect(Item.search_by_price(500.00, 1000.00)).to eq(item_3)
      end
    end
  end
end
