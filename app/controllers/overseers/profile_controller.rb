class Overseers::ProfileController < Overseers::BaseController
	def edit
		@overseer = current_overseer
		authorize @overseer
	end

	def update
		@overseer = current_overseer
		@overseer.assign_attributes(profile_params)
		authorize @overseer

		if @overseer.save
			redirect_to edit_overseers_profile_path, notice: flash_message(@overseer, action_name)
		else
			render 'edit'
		end
	end

	private

	def profile_params
		params.require(:overseer).permit(
				:first_name,
				:last_name,
				:mobile,
				:telephone,
				:smtp_password,
				:slack_uid,
		)
	end
end
