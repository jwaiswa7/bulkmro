module ShortcutsHelper
  def current_model
    controller_name.capitalize.pluralize
  end

  def row_action_button(url, icon, title = '', color = 'success', target = :_self, method = :get, data = '', remote = false, label = '')
    link_to url, 'data-toggle': 'tooltip', 'data-placement': 'top', target: target, title: title, method: method, remote: remote, class: ['btn btn-sm btn-', color].join, data: data do
      concat content_tag(:span, label)
      concat content_tag :i, nil, class: ['fal fa-', icon].join
    end
  end

  def modal_button(icon, title = '', color = 'warning', id)
    link_to '', 'data-toggle': 'modal', 'data-target': '#myModal', title: title, data: {entity_id: id}, class: ['btn btn-sm btn-', color].join do
      concat content_tag :i, nil, class: ['fal fa-', icon].join
    end
  end

  def breadcrumbs(page_title = nil, controller_is_aliased = false)
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

      name = page_title if page_title.present? && name == controller_name.titleize

      if (index + 1) == elements.size
        crumbs << (content_tag :li, class: 'breadcrumb-item' do
          name = prev_element.singularize.titleize if controller_is_aliased == 'true'
          name
        end)
      else
        crumbs << (content_tag :li, class: 'breadcrumb-item' do
          begin
            route = recognize_path(path_so_far)
            if route
              file_path = File.join('app/views/', "#{route[:controller]}/#{route[:action]}.html.erb")
              if File.exist?(file_path)
                link_to name, path_so_far
              else
                name
              end
            end
          rescue ActionController::RoutingError => e
            name
          end
        end)
      end
    end

    crumbs.join
  end

  def submit_text(obj, use_alias: nil, suffix: nil)
    class_name = use_alias ? use_alias.humanize : obj.class.model_name.human
    if suffix.blank?
      suffix = ''
    end
    if obj.new_record?
      "Create #{class_name.titleize} #{suffix.humanize}"
    else
      "Update #{class_name.titleize} #{suffix.humanize}"
    end
  end

  def get_entry(entries, *attributes)
    if entries[attributes[0]].present? && entries[attributes[0]][attributes[1]].present?
      entries[attributes[0]][attributes[1]]
    else
      0
    end
  end

end
