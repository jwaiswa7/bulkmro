# frozen_string_literal: true

module MenuHelper
  def active_if_path_is(path = nil)
    return nil if path.nil? || request.nil?

    request.path == path ? 'active' : nil
  end

  def show_if(bool)
    'show' if bool
  end

  def current_controller?(path)
    controller_path.include? recognize_path(path)[:controller]
  end

  def only_current_controller?(path, method: :get)
    controller_path.eql? recognize_path(path, method: method)[:controller]
  end

  def current_action?(path)
    recognized_path = recognize_path(path)
    controller_path.include?(recognized_path[:controller]) &&
      action_name.include?(recognized_path[:action])
  end

  def recognize_path(path, method: :get)
    Rails.application.routes.recognize_path(path, method: method)
  end

  def menu_item(name, path, authorized: false)
    if authorized
      content_tag(:li, class: active_if_path_is(path)) do
        content_tag(:a, href: path) do
          name
        end
      end
    end
  end

  def nav_item(name, path, authorized = false, li_classes = nil, a_classes = nil, attributes: nil)
    if authorized
      content_tag(:li, class: ['nav-item', li_classes].compact.join(' ')) do
        content_tag(:a, class: [active_if_path_is(path), 'nav-link', a_classes].compact.join(' '), href: path, role: 'tab') do
          name
        end
      end
    end
  end

  def nav_dropdown_item(name, path, authorized = false, _li_classes = nil, a_classes = nil, attributes: nil)
    if authorized
      content_tag(:a, class: [active_if_path_is(path), 'dropdown-item', a_classes].compact.join(' '), href: path, role: 'tab') do
        name
      end
    end
  end
end
