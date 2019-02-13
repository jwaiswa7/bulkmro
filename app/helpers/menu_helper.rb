

module MenuHelper
  def active_if_path_is(path=nil)
    if path == nil || request == nil; return nil; end
    request.path == path ? "active" : nil
  end

  def show_if(bool)
    if bool
      "show"
    else
      nil
    end
  end

  def current_controller?(path)
    self.controller_path.include? recognize_path(path)[:controller]
  end

  def only_current_controller?(path, method: :get)
    self.controller_path.eql? recognize_path(path, method: method)[:controller]
  end

  def current_action?(path)
    recognized_path = recognize_path(path)
    self.controller_path.include? recognized_path[:controller] and
        self.action_name.include? recognized_path[:action]
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

  def nav_item(name, path, authorized=false, li_classes=nil, a_classes=nil, attributes: nil)
    if authorized
      content_tag(:li, class: ["nav-item", li_classes].compact.join(" ")) do
        content_tag(:a, class: [active_if_path_is(path), "nav-link", a_classes].compact.join(" "), href: path, role: "tab") do
          name
        end
      end
    end
  end

  def nav_dropdown_item(name, path, authorized=false, li_classes=nil, a_classes=nil, attributes: nil)
    if authorized
      content_tag(:a, class: [active_if_path_is(path), "dropdown-item", a_classes].compact.join(" "), href: path, role: "tab") do
        name
      end
    end
  end
end
