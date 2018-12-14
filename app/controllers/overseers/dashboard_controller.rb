class Overseers::DashboardController < Overseers::BaseController
  skip_before_action :authenticate_overseer!, only: :migrations

  def show
    authorize :dashboard, :show?
    if(current_overseer.role == "inside_sales_executive")
      @dashboard = Overseers::Dashboard.new(current_overseer)
    end
  end

  def serializer
    authorize :dashboard, :show?
    render json: Serializers::InquirySerializer.new(Inquiry.find(1004), {
        include: [
        ]}).serialized_json
  end

  def chewy
    authorize :dashboard
    Dir[[Chewy.indices_path, "/*"].join()].map do |path|
      path.gsub(".rb", "").gsub("app/chewy/", "").classify.constantize.reset!
    end
    # Fix for failure when no shards are found
    redirect_back fallback_location: overseers_dashboard_path
  end

  def reset_index
    authorize :dashboard
    if params.present? && params[:index].present?
      index_class = params[:index].to_s.classify.constantize
      if index_class <= BaseIndex
        index_class.reset!
      end
    end
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

  attr_accessor :overseer
end