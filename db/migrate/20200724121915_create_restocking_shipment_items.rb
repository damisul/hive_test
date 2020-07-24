class CreateRestockingShipmentItems < ActiveRecord::Migration[6.0]
  def change
    create_table :restocking_shipment_items do |t|
      t.references :sku, null: false, foreign_key: true
      t.references :restocking_shipment, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.timestamps
      t.index [:sku_id, :restocking_shipment_id], unique: true, name: 'index_rest_shp_items_sku_shipment'
    end
  end
end
