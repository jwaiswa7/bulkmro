module ShortcutsHelper
  def current_model
    controller_name.capitalize.pluralize
  end

  def row_action_button(url, icon, title='', color='success', target=:_self)
    link_to url, :'data-toggle' => 'tooltip', :'data-placement' => 'top', :target => target, :title => title, class: ['btn btn-sm btn-', color].join do
      concat content_tag :i, nil, class: ['fal fa-', icon].join
    end
  end

  def breadcrumbs
    full_path = request.path
    path_so_far = '/'
    elements = full_path.split('/').reject { |e| e.blank? }
    crumbs = []

    elements.each_with_index do |element, index|
      path_so_far += [element, '/'].join
      name = element.titleize

      begin
        prev_element = elements[index - 1]

        if prev_element.classify.constantize && prev_element.classify.constantize.find(element.remove('_'))
          name = prev_element.classify.constantize.find(element).to_s
        end
      rescue NameError => e
        # Default name is used
      rescue ActiveRecord::RecordNotFound => e
        # Default name is used
      end if index > 0

      if (index + 1) == elements.size
        crumbs << (content_tag :li, class: 'breadcrumb-item' do
          name
        end)
      else
        crumbs << (content_tag :li, class: 'breadcrumb-item' do
          link_to name, path_so_far
        end)
      end
    end

    crumbs.join
  end

  def submit_text(obj, use_alias: nil, suffix: nil)
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