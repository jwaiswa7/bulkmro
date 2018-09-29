class Overseers::DashboardController < Overseers::BaseController
  def show
    authorize :dashboard, :show?

  end

  def serializer
    # InquiryIndex.delete
    # InquiryIndex.create!
    # InquiryIndex.import
    # InquiriesIndex.reset!
    # ProductsIndex.reset!
    #
    # Inquiry.search('asd')
    #
    #
    authorize :dashboard, :show?
    render json: Serializers::InquirySerializer.new(Inquiry.find(1004), {
        include: [
        ]}).serialized_json
  end

  def chewy
    # InquiryIndex.delete
    # InquiryIndex.create!
    # InquiryIndex.import
    # InquiriesIndex.reset!
    # ProductsIndex.reset!
    #
    # Inquiry.search('asd')
    #
    #
  end
end
