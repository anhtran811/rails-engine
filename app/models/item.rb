class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items, dependent: :destroy
  
  validates :name, :description, :merchant_id, presence: true
  validates :unit_price, presence: true, numericality: true 

  def self.search_by_name(name_params)
    where("name ILIKE ?", "%#{name_params}%")
    .order(:name)
    .first
  end

  def self.search_by_price(min, max)
    if max == nil
      where("unit_price >= ?", "#{min}").order(:name).first
    elsif min == nil
      where("unit_price <= ?", "#{max}").order(:name).first
    end
  end
end