class Item < ApplicationRecord
  belongs_to :merchant
  
  validates :name, :description, :merchant_id, presence: true
  validates :unit_price, presence: true, numericality: true 
end