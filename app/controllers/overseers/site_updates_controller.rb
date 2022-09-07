class Overseers::SiteUpdatesController < Overseers::BaseController
	def show
		@site_updates=CSV.parse(SiteUpdate.last.attachment.download, headers: true)
    end

	def create
		authorize SiteUpdate
		@site_update = SiteUpdate.new(site_updates_params)
		if @site_update.save
			redirect_to release_notes_path(), notice: flash_message(@site_update, action_name)
		else
			@site_updates=SiteUpdate.last
			redirect_to release_notes_path(), notice: "Please Upload file in Correct Format"
		end
	end

	private	

	def site_updates_params
		params.require(:site_update).permit(
			:attachment
		)
	end
		
end