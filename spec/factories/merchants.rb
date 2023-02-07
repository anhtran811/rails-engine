FactoryBot.define do
  factory :merchant do
    name { Faker::Movies::HarryPotter.character }
  end
end
