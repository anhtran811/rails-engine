FactoryBot.define do
  factory :customer do
    first_name {Faker::TvShows::GameOfThrones.character}
    last_name {Faker::TvShows::Friends.character}
  end
end