module FormHelper
	def enum_to_collection(enum, keep_raw: false, all_caps: false, alphabetical: true)
    collection = enum.keys.to_a
		collection.sort! if alphabetical

		collection.map do |w|
			if keep_raw
				[w, w]
			elsif all_caps
				[w.upcase, w]
			else
				[w.humanize, w]
			end
		end
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

  def selected_option_or_nil(form_object, attribute_name)
		attribute = form_object.object.send(attribute_name)

		if attribute.present?
			[attribute]
		else
			[]
		end
	end
end