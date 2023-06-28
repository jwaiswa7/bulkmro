class Overseers::PendingSyncsController < Overseers::BaseController

    def index 
       
       respond_to do |format|
         format.json do 
          @inquiries = ApplyDatatableParams.to(Inquiry.where(opportunity_uid: nil).order(id: :desc), params)
         end
         format.html
       end
    end

    def resync_all 

    end

    def resync 

    end

    def resync_urgent 
      
    end
end