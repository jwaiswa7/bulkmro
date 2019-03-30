class Services::Overseers::Reports::InwardLogisticQueue < Services::Overseers::Reports::BaseReport
  def call
    purchase_orders = PurchaseOrder.includes(:inward_dispatches).includes(:po_request)

    @data = OpenStruct.new(
      entries: {}
    )

    logistic_overseers = Overseer.where(role: 'logistics')
    logistic_overseers.each do |logistic_overseer|
      data.entries[logistic_overseer.id] = { name: logistic_overseer.to_s}
    end
    attr_accessor :data
  end
end