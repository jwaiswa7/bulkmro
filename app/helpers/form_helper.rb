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

	def html_id_for(html_text)
		/id="([a-z\d_]*)"/.match(html_text)[1]
	end

  def placeholder_for(f, name)
		singular = ['simple_form', 'placeholders', f.object.class.name.underscore, name].join('.')
		plural = ['simple_form', 'placeholders', f.object.class.name.underscore.pluralize, name].join('.')

		if I18n.exists?(singular, I18n.locale)
			I18n.t(singular, I18n.locale)
		else
			I18n.t(plural, I18n.locale)
		end
	end

end