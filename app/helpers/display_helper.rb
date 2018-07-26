module DisplayHelper
  include ActionView::Helpers::NumberHelper

  def format_status(status)
    case status.to_sym
      when :active
        content_tag(:div, class: 'status-pill green', :'data-title' => status.humanize, :'data-toggle' => 'tooltip') do; end
      else
        content_tag(:div, class: 'status-pill red', :'data-title' => status.humanize, :'data-toggle' => 'tooltip') do; end
    end
  end

  def format_status_label(status)
    case status.to_sym
      when :pending
        content_tag :span, capitalize(status), class: 'label label-danger'
      else
        content_tag :span, capitalize(status), class: 'label label-success'
    end
  end

  def format_enum(val)
    val.humanize if val.present?
  end

  def percentage(number)
    if number
      [number_with_precision(number * 100, precision: 0), '%'].join
    end
  end

  def capitalize(text)
    text.to_s.humanize if text
  end

  def format_currency(amount, currency: nil, precision: 2, plus_if_positive: false, show_symbol: true, floor: false)
    [amount > 0 && plus_if_positive ? '+' : nil, amount < 0 ? '-' : nil, show_symbol ? (currency || currency.default).sign : nil, number_with_precision(floor ? amount.abs.floor : amount.abs, :precision => precision, delimiter: ',')].join if amount.present?
  end

  def format_collection(kollection)
    kollection.map(&:to_s).to_sentence
  end

  def format_size(kollection)
    [kollection.size, kollection.class.to_s.split('::').first.downcase.pluralize].join(' ')
  end

  def currency_sign(currency)
    content_tag :span do
      currency.sign
    end
  end

  def format_id(id, prefix: nil)
    if prefix
      "##{prefix}#{id}"
    else
      "##{id}"
    end
  end

  def format_date(date, format=:short)
    if date.present?
      date.to_formatted_s format
    end
  end

  def format_int(num)
    num.to_int
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