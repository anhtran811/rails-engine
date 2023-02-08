FactoryBot.define do
  factory :invoice_item do
    quantity { [0..100].sample } 
    unit_price { Faker::Number.decimal(l_digits: 2) }
    association :invoice, :item
  end
end