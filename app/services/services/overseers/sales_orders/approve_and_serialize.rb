class Services::Overseers::SalesOrders::ApproveAndSerialize < Services::Shared::BaseService
  def initialize(sales_order, comment)
    @sales_order = sales_order
    @comment = comment
    @overseer = comment.overseer
  end

  def call
    ActiveRecord::Base.transaction do
      @sales_order.create_approval(
          :comment => @comment,
          :overseer => overseer,
          :metadata => Serializers::InquirySerializer.new(@sales_order.inquiry)
      )

      @sales_order.update_attributes(
          :status => :"SAP Approval Pending"
      )

      @sales_order.serialized_pdf.attach(io: File.open(RenderPdfToFile.for(@sales_order)), filename: @sales_order.filename)
      @sales_order.update_index
      @sales_order.save_and_sync
    end
  end

  attr_reader :sales_order, :overseer, :comment
end