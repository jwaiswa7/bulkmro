class ApplyParamsToArray < BaseFunction
	 def self.to(records, params)
 		 # Set search query
 		 if params[:_type] == 'query' && params[:q].present?
			 begin
  			 records = records.grep(/^#{params[:q]}/)
			 rescue StandardError => e
				  p "-----------------------#{e}"
			 end
  		end
		  Kaminari.paginate_array(records).page(params[:page])
 	end
end
