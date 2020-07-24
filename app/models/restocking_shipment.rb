class RestockingShipment < ApplicationRecord
  belongs_to :shipment_provider
  belongs_to :user
  enum status: {
    processing: 1,
    shipped: 2,
    cancelled: 3
  }
  has_many :items, class_name: :RestockingShipmentItem, inverse_of: :restocking_shipment
  validates_numericality_of :shipping_cost, greater_than: 0, allow_nil: false
  validates_presence_of :shipment_provider, :user, :status, :items

  accepts_nested_attributes_for :items
end
