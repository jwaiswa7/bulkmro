# frozen_string_literal: true

class Overseers::ProfileController < Overseers::BaseController
	 def edit
 		 @overseer = current_overseer
 		 authorize :profile
 	end

	 def update
 		 @overseer = current_overseer
 		 @overseer.assign_attributes(profile_params)
 		 authorize :profile

 		 if @overseer.save
  			 redirect_to edit_overseers_profile_path, notice: flash_message(@overseer, action_name)
  		else
  			 render "edit"
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
