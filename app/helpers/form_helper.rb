module FormHelper
	def enum_to_collection(enum, all_caps: false)
    enum.keys.to_a.map { |w| [all_caps ? w.upcase : w.humanize, w] }
  end

	def disabled_if(condition)
		condition ? 'disabled' : nil
	end

	def format_submit_text(obj, use_alias: nil, suffix: nil)
		class_name = use_alias ? use_alias.humanize : obj.class.name
		if obj.new_record?
			"Create #{class_name}"
		else
			if suffix.present?
				"Update #{class_name} #{suffix.humanize}"
			else
				"Update #{class_name}"
			end
		end
	end

end