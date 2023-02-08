require 'rails_helper' do
  RSpec.describe Transaction, type: :model do
    describe 'relationships' do
      it { should belong_to(:invoice) }
    end
  end 
end