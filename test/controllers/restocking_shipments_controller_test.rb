require 'test_helper'

class RestockingShipmentsControllerTest < ActionDispatch::IntegrationTest
  def auth_header(user)
    token = TokenUtils.encode(user_id: user.id)
    return {Authorization: "Bearer #{token}"}
  end

  test 'Create Succeed and status set to processing by default' do
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
      }, headers: auth_header(user), as: :json
    end

    assert_response :success

    s = RestockingShipment.order(id: :desc).first
    assert s.processing?
    assert_equal 50.35, s.shipping_cost
    assert_equal user, s.user
    assert_equal 2, s.items.count

    item = s.items.where(sku: necklace).first
    assert_equal 100, item.quantity

    item = s.items.where(sku: bracelet).first
    assert_equal 150, item.quantity
  end

  test 'Create Succeed and explicit status set' do
    provider = shipment_providers(:dhl)
    user = users(:bob)
    necklace = skus(:necklace)
    bracelet = skus(:bracelet)

    assert_difference 'RestockingShipment.count' => 1, 'RestockingShipmentItem.count' => 2 do
      post '/restocking_shipments', params: {
          shipment_provider_id: provider.id,
          shipping_cost: 50.35,
          status: :cancelled,
          skus: [
              { id: necklace.id, quantity: 100 },
              { id: bracelet.id, quantity: 150 }
          ]
      }, headers: auth_header(user), as: :json
    end

    assert_response :success

    s = RestockingShipment.order(id: :desc).first
    assert s.cancelled?
    assert_equal 50.35, s.shipping_cost
    assert_equal user, s.user
    assert_equal 2, s.items.count

    item = s.items.where(sku: necklace).first
    assert_equal 100, item.quantity

    item = s.items.where(sku: bracelet).first
    assert_equal 150, item.quantity
  end

  test 'Create failed when required param is missing' do
    provider = shipment_providers(:dhl)
    user = users(:alice)
    necklace = skus(:necklace)
    bracelet = skus(:bracelet)

    assert_no_difference 'RestockingShipment.count', 'RestockingShipmentItem.count' do
      post '/restocking_shipments', params: {
        shipment_provider_id: provider.id,
        skus: [
          { id: necklace.id, quantity: 100 },
          { id: bracelet.id, quantity: 150 }
        ]
      }, headers: auth_header(user), as: :json
    end
    assert_response :bad_request
    assert_equal 'Required param missing: shipping_cost', response.body
  end

  test 'Create failed when empty items list is passed' do
    provider = shipment_providers(:dhl)
    user = users(:alice)

    assert_no_difference 'RestockingShipment.count', 'RestockingShipmentItem.count' do
      post '/restocking_shipments', params: {
          shipment_provider_id: provider.id,
          shipping_cost: 50.35,
          skus: []
      }, headers: auth_header(user), as: :json
    end
    assert_response :bad_request
    assert_equal 'Required param missing: skus', response.body
  end

  test 'Create failed when wrong sku is passed' do
    provider = shipment_providers(:dhl)
    user = users(:alice)
    necklace = skus(:necklace)

    assert_no_difference 'RestockingShipment.count', 'RestockingShipmentItem.count' do
      post '/restocking_shipments', params: {
          shipment_provider_id: provider.id,
          shipping_cost: 50.35,
          skus: [
              { id: necklace.id, quantity: 100 },
              { id: -1, quantity: 150 }
          ]
      }, headers: auth_header(user), as: :json
    end
    assert_response :not_found
    assert_equal 'Sku with id = -1 not found', response.body
  end

  test 'Create failed when zero quantity is passed' do
    provider = shipment_providers(:dhl)
    user = users(:alice)
    necklace = skus(:necklace)

    assert_no_difference 'RestockingShipment.count', 'RestockingShipmentItem.count' do
      post '/restocking_shipments', params: {
          shipment_provider_id: provider.id,
          shipping_cost: 50.35,
          skus: [
              { id: necklace.id, quantity: 0 },
          ]
      }, headers: auth_header(user), as: :json
    end
    assert_response :unprocessable_entity
    assert_equal 'Some data are wrong: Validation failed: Items quantity must be greater than 0', response.body
  end

  test 'Create failed when wrong provider passed' do
    user = users(:alice)
    necklace = skus(:necklace)

    assert_no_difference 'RestockingShipment.count', 'RestockingShipmentItem.count' do
      post '/restocking_shipments', params: {
          shipment_provider_id: -1,
          shipping_cost: 50.35,
          skus: [
              { id: necklace.id, quantity: 100 }
          ]
      }, headers: auth_header(user), as: :json
    end
    assert_response :not_found
    assert_equal 'ShipmentProvider with id = -1 not found', response.body
  end

  test 'Create failed when validation failed' do
    provider = shipment_providers(:dhl)
    user = users(:alice)
    necklace = skus(:necklace)

    assert_no_difference 'RestockingShipment.count', 'RestockingShipmentItem.count' do
      post '/restocking_shipments', params: {
          shipment_provider_id: provider.id,
          shipping_cost: -50.35,
          skus: [
              { id: necklace.id, quantity: 100 }
          ]
      }, headers: auth_header(user), as: :json
    end
    assert_response :unprocessable_entity
    assert_equal 'Some data are wrong: Validation failed: Shipping cost must be greater than 0', response.body
  end
end
