require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
    it { should have_many(:invoices) }
    it { should have_many(:invoice_items).through(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'class methods' do
    describe ":search_all_by_name" do
      it 'returns all merchants, alphabeticaly, with case-insensitive and partial search parameters' do
        merchant_1 = create(:merchant, name: "Harry Potter")
        merchant_2 = create(:merchant, name: "Hermione Granger")
        merchant_3 = create(:merchant, name: "Ronald Weasley")
        merchant_4 = create(:merchant, name: "Severus Snape")

        expect(Merchant.search_all_by_name("er")).to eq([merchant_1, merchant_2, merchant_4])
      end
    end
  end
end
