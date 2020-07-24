class RestockingShipmentsController < ApplicationController
  def create
    shipment_provider_id = params.require(:shipment_provider_id)
    shipment_provider = ShipmentProvider.find(shipment_provider_id)

    shipping_cost = params.require(:shipping_cost)
    status = params[:status] || 'processing' # status is an optional param
    items = params.require(:skus).
      map { |sku| RestockingShipmentItem.new(sku: Sku.find(sku[:id]), quantity: sku[:quantity]) }

    # fix later
    u = User.find_by(name: 'Alice')

    s = RestockingShipment.create!(
      shipment_provider: shipment_provider,
      user: u,
      shipping_cost: shipping_cost,
      status: status,
      items: items
    )
    render plain: 'OK'
  rescue ActiveRecord::RecordNotFound => e
    render plain: "#{e.model} with id = #{e.id} not found", status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render plain: "Some data are wrong: #{e.message}", status: :unprocessable_entity
  rescue => e
    # In real app I would reported them to service like Bugsnag
    puts e.message
    puts e.backtrace.join("\n")
    render  status: :internal_server_error
  end
end
