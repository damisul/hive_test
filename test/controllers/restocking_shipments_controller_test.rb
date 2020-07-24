require 'test_helper'

class RestockingShipmentsControllerTest < ActionDispatch::IntegrationTest
  test 'Create Succeed' do
    provider = shipment_providers(:dhl)
    user = users(:alice)
    necklace = skus(:necklace)
    bracelet = skus(:bracelet)

    assert_difference 'RestockingShipment.count' => 1, 'RestockingShipmentItem.count' => 2 do
      post '/restocking_shipments', params: {
          shipment_provider_id: provider.id,
          shipping_cost: 50.35,
          skus: [
              { id: necklace.id, quantity: 100 },
              { id: bracelet.id, quantity: 150 }
          ]
      }, xhr: true
    end

    s = RestockingShipment.order(id: :desc).first
    assert s.processing?
    assert_equal 50.35, s.shipping_cost
    assert_equal user, s.user
    assert_equal 2, s.items.count

    item = s.items.where(sku: necklace).first
    assert_equal 100, item.quantity

    item = s.items.where(sku: bracelet).first
    assert_equal 150, item.quantity

    assert_response :success
  end
end
