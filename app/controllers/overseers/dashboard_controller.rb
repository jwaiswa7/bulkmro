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
    # InquiriesIndex.delete
    # InquiriesIndex.create!
    # InquiryIndex.import
    InquiriesIndex.reset!
    ProductsIndex.reset!

    # Fix for failure when no shards are found
    redirect_back fallback_location: overseers_dashboard_path
  end

  def console
    authorize :dashboard
  end

  def migrations
    authorize :dashboard
    Services::Shared::Migrations::Migrations.new.call
    render json: {}, status: :ok
  end
end
