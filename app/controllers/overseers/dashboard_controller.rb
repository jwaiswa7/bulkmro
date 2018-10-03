class Overseers::DashboardController < Overseers::BaseController
  skip_before_action :authenticate_overseer!, only: :migrations

  def show
    authorize :dashboard, :show?
  end

  def serializer
    authorize :dashboard, :show?
    render json: Serializers::InquirySerializer.new(Inquiry.find(1004), {
        include: [
        ]}).serialized_json
  end

  def chewy
    authorize :dashboard
    # InquiryIndex.delete
    # InquiryIndex.create!
    # InquiryIndex.import
    InquiriesIndex.reset!
    ProductsIndex.reset!

    # Fix for failure when no shards are found
    render json: {}, status: :ok
  end

  def migrations
    Services::Shared::Migrations::Migrations.new
  end
end
