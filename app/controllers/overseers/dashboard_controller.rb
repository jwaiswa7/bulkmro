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
    ProductsIndex.delete
    ProductsIndex.create!
    ProductsIndex.reset!

    # InquiryIndex.import
    InquiriesIndex.reset!
    SalesOrdersIndex.reset!


    InquiriesIndex.delete
    InquiriesIndex.create!
    InquiriesIndex.reset!

    # Fix for failure when no shards are found
    redirect_back fallback_location: overseers_dashboard_path
  end

   def reset_indices
     authorize :dashboard




     # Fix for failure when no shards are found
     redirect_back fallback_location: overseers_dashboard_path
   end

  def console
    authorize :dashboard

    Services::Overseers::Inquiries::RefreshCalculatedTotals.new.call
    # render json: Resources::BusinessPartner.find('3095267094', quotes: true)
  end

  def migrations
    authorize :dashboard
    Services::Shared::Migrations::Migrations.new.call
    render json: {}, status: :ok
  end
end
