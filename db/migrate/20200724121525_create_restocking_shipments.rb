class CreateRestockingShipments < ActiveRecord::Migration[6.0]
  def change
    create_table :restocking_shipments do |t|
      t.references :shipment_provider, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false
      t.decimal :shipping_cost, null: false, precision: 8, scale: 2
      t.timestamps
    end
  end
end
