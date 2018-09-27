class ApplyDatatableParams < BaseFunction
	def self.to(records, params, if_no_search_term: nil, unscoped_if_search_term: false)
		if params[:search] && params[:search][:value].present?
			records = records.unscoped if unscoped_if_search_term
			records = records.locate(params[:search][:value])
		else
			if if_no_search_term
				return if_no_search_term
			end
		end

		if params[:order]
			params[:order].each do |k, v|
        column_id = v[:column]
        direction = v[:dir].to_sym
				column_name = params[:columns][column_id][:name]

				records = records.order(column_name.to_sym => direction) if column_name.present?
			end
		else
			records = records.latest
		end

		page = params[:start] && params[:length] ? (params[:start].to_i / params[:length].to_i) + 1 : 1
		per = params[:length] ? params[:length].to_i : 25
		records = records.page(page).per(per)
		records
	end
end