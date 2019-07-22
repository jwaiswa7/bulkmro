class Services::Overseers::SalesOrders::ApproveAndSerialize < Services::Shared::BaseService
  def initialize(sales_order, comment)
    @sales_order = sales_order
    @comment = comment
    @overseer = comment.overseer
  end

  def call
    ActiveRecord::Base.transaction do
      @sales_order.create_approval(
        comment: @comment,
        overseer: overseer,
        metadata: Serializers::InquirySerializer.new(@sales_order.inquiry)
      )

      @sales_order.update_attributes(
        manager_so_status_date: Time.now
      )

      if @sales_order.status != 'Approved'
        @sales_order.update_attributes(
          status: :"Accounts Approval Pending",
        )
      end
      @sales_order.serialized_pdf.attach(io: File.open(RenderPdfToFile.for(@sales_order)), filename: @sales_order.filename)

      @sales_order.billing_address =  make_duplicate_address(@sales_order.inquiry.billing_address)
      @sales_order.shipping_address = make_duplicate_address(@sales_order.inquiry.shipping_address)

      @sales_order.update_index
      @sales_order.save
    end
  end

  private

    def make_duplicate_address(address)
      duplicate_address = address.dup
      duplicate_address.company_id = nil
      duplicate_address.remote_uid = nil
      duplicate_address.save
      duplicate_address
    end

    attr_reader :sales_order, :overseer, :comment
end
