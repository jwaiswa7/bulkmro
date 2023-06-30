class Services::Overseers::Inquiries::ResyncAll < Services::Shared::BaseService
  
    def call 
        inquiries = Inquiry.where(opportunity_uid: nil).order(id: :desc)
        inquiries.each do |inquiry|
            inquiry.save_and_sync
        end
    end
end