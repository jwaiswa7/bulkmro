class ApplyParams < BaseFunction
	 def self.to(records, params)
 		 # Set search query
 		 if params[:_type] == 'query' && params[:q].present?
			 begin
  			 records = records.locate(params[:q])
			 rescue StandardError => e
				  p "-----------------------#{e}"
			 end
  		end

 		 records.page(params[:page])
 	end
end
