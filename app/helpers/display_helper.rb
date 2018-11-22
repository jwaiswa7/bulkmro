module DisplayHelper
  include ActionView::Helpers::NumberHelper

  # def format_status(status)
  #   case status.to_sym
  #     when :active
  #       content_tag(:div, class: 'status-pill green', :'data-title' => status.humanize, :'data-toggle' => 'tooltip') do; end
  #     else
  #       content_tag(:div, class: 'status-pill red', :'data-title' => status.humanize, :'data-toggle' => 'tooltip') do; end
  #   end
  # end

  def upcase(string)
    string.upcase
  end

  def format_class(klass)
    klass.class.name
  end

  def format_enum(val, humanize_text: true)
    val.to_s.truncate(17) if val.present?
    if humanize_text
      val.humanize
    else
      val
    end if val.present?
  end

  def day_count(val)
    if val == 1
      "#{val} day"
    else
      "#{val} days"
    end
  end

  def percentage(number, precision: 0)
    if number && !number.nan?
      [number_with_precision(number, precision: precision), '%'].join
    end
  end

  def capitalize(text)
    text.to_s.humanize if text
  end

  def format_currency(amount, symbol: nil, precision: 2, plus_if_positive: false, show_symbol: true, floor: false)
    if amount.present?
      [amount > 0 && plus_if_positive ? '+' : nil, amount < 0 ? '-' : nil, show_symbol ? (symbol || '₹') : nil, number_with_precision(floor ? amount.abs.floor : amount.abs, :precision => precision, delimiter: ',')].join if amount.present?
    else
      "-"
    end
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
    ['#', id].join if id.present?
  end

  def format_date(date)
    if date.present?
      #date.strftime("%e %b, %Y %H:%M")
      date.strftime("%d-%b-%Y")
    else
      "-"
    end
  end

  def format_date_with_time(date)
    if date.present?
      #date.strftime("%e %b, %Y %H:%M")
      date.strftime("%d-%b-%Y %H:%M")
    else
      "-"
    end
  end


  def format_date_without_time(date)
    if date.present?
      date.strftime("%d-%b-%Y")
    end
  end

  def format_date_without_time_and_date(date)
    if date.present?
      date.strftime("%b-%Y")
    end
  end

  def format_num(num, precision = 0)
    number_with_precision(num, precision: precision)
  end

  def format_int(num)
    num.to_int
  end

  def format_month(date)
    if date.present? && (date.is_a?(DateTime) || date.is_a?(Date))
      date.strftime('%b, %Y')
    else
      date.to_s.titleize
    end
  end

  def format_month_without_date(month)
    month.to_date.strftime('%b, %Y')
  end

  def format_collection(kollection)
    kollection.map(&:to_s).to_sentence
  end

  def format_badge(text, color)
    content_tag :span, class: "badge text-uppercase badge-#{color}" do
      content_tag :strong, text.to_s.capitalize
    end
  end

  def format_boolean(true_or_false)
    (true_or_false ? '<i class="far fa-check text-success"></i>' : '<i class="far fa-times text-danger"></i>').html_safe
  end

  def format_boolean_label(true_or_false, verb = '')
    yes = verb ? verb : 'Yes'
    no = verb ? ['Not', verb].join(' ') : 'No'
    (true_or_false ? ['<span class="badge badge-success text-uppercase">', yes, '</span>'].join('') : ['<span class="badge badge-danger text-uppercase">', no, '</span>'].join('')).html_safe
  end

  def format_count(count, zero_if_nil: true)
    if count.present?
      count
    elsif zero_if_nil
      0
    else
      nil
    end
  end
end