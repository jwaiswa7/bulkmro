

class ApplyParams < BaseFunction
	 def self.to(records, params)
 		 # Set search query
 		 if params[:_type] == "query" && params[:q].present?
  			 records = records.locate(params[:q])
  		end

 		 records.page(params[:page])
 	end
end
