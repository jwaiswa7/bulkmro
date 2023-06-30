class Overseers::PendingSyncsController < Overseers::BaseController
   
    before_action :validate_super_admin
    before_action :set_inquiry, only: [:resync, :resync_urgent]



    def index 
       
       respond_to do |format|
         format.json do 
          @inquiries = ApplyDatatableParams.to(Inquiry.where(opportunity_uid: nil).order(id: :desc), params)
         end
         format.html
       end
    end

    def resync_all 
      service = Services::Overseers::Inquiries::ResyncAll.new 
      service.call
      redirect_to overseers_pending_syncs_path, notice: "Resyncing all inquiries"
    end

    def resync 
      @inquiry.save_and_sync
      redirect_to overseers_pending_syncs_path, notice: "Resyncing inquiry #{@inquiry.inquiry_number}"
    end

    def resync_urgent 
      service = Services::Resources::Inquiries::SaveAndSync.new(@inquiry, true)
      service.call
      redirect_to overseers_pending_syncs_path, notice: "Resync urget inquiry #{@inquiry.inquiry_number}}"
    end
    private 

    def validate_super_admin
      redirect_to root_path, notice: 'You are not authorized' unless current_overseer.is_super_admin?
    end

    def set_inquiry 
      @inquiry = Inquiry.find(params[:pending_sync_id])
    end
end