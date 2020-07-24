class RestockingShipmentItem < ApplicationRecord
  belongs_to :restocking_shipment, inverse_of: :items
  belongs_to :sku

  validates_numericality_of :quantity, greater_than: 0, only_integer: true, allow_nil: false
  validates_presence_of :restocking_shipment, :sku
end
