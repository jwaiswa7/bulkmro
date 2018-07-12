class ApplyParams < BaseFunction
	def self.to(records, params, if_no_search_term: nil)
		if params[:search] && params[:search][:value].present?
			records = records.locate(params[:search][:value])
		else
			if if_no_search_term
				return if_no_search_term
			end
		end

		# if params[:sorts]
		# 	params[:sorts].each do |k, v|
		# 		records = records.order(k.to_sym => (v.to_i == 1 ? :asc : :desc), :created_at => :desc)
		# 	end
		# else
		# 	records = records.latest
		# end

    page = params[:start] && params[:length] ? (params[:start].to_i / params[:length].to_i) + 1 : 1
    per = params[:length] ? params[:length].to_i : 10
 		records = records.page(page).per(per)
		records
	end
end