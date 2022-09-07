class Overseers::SiteUpdatesController < Overseers::BaseController
	before_action :set_site_update

	def show
    end

	def create
		authorize SiteUpdate
		@site_update = SiteUpdate.new(site_updates_params)
		if @site_update.save
			redirect_to release_notes_path(), notice: flash_message(@site_update, action_name)
		else
			redirect_to release_notes_path(), notice: "Please Upload file in Correct Format"
		end
	end

	private	

	def site_updates_params
		params.require(:site_update).permit(
			:attachment
		)
	end

	def set_site_update
		@site_updates=CSV.parse(SiteUpdate.last.attachment.download, headers: true) if SiteUpdate.last.try(:attachment).present?
	end
		
end