class RestockingShipmentsController < ApplicationController
  def create
    shipment_provider_id = params.require(:shipment_provider_id)
    shipment_provider = ShipmentProvider.find(shipment_provider_id)

    shipping_cost = params.require(:shipping_cost)
    status = params[:status] || 'processing' # status is an optional param
    items = params.require(:skus).
      map { |sku| RestockingShipmentItem.new(sku: Sku.find(sku[:id]), quantity: sku[:quantity]) }

    s = RestockingShipment.create!(
      shipment_provider: shipment_provider,
      user: @current_user,
      shipping_cost: shipping_cost,
      status: status,
      items: items
    )
    render plain: 'OK'
  rescue ActionController::ParameterMissing => e
    render plain: "Required param missing: #{e.param}", status: :bad_request
  rescue ActiveRecord::RecordNotFound => e
    render plain: "#{e.model} with id = #{e.id} not found", status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render plain: "Some data are wrong: #{e.message}", status: :unprocessable_entity
  rescue => e
    # In real app I would reported them to service like Bugsnag
    puts "#{e.class.name}: #{e.message}"
    puts e.backtrace.join("\n")
    render  status: :internal_server_error
  end
end
