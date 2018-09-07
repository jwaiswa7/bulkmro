class Services::Overseers::SalesOrders::ApproveAndSerialize < Services::Shared::BaseService
  def initialize(sales_order, comment)
    @sales_order = sales_order
    @comment = comment
    @overseer = comment.overseer
  end

  def call
    @sales_order.create_approval(
        :comment => @comment,
        :overseer => overseer,
        :metadata => Serializers::InquirySerializer.new(@sales_order.inquiry)
    )
  end

  attr_reader :sales_order, :overseer, :comment
end