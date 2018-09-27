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

  def format_status_label(status)
    case status.to_sym
    when :active
      content_tag :span, class: 'badge text-uppercase badge-warning' do
        content_tag :strong, capitalize(status)
      end
    when :won
      content_tag :span, capitalize(status), class: 'badge text-uppercase badge-success' do
        content_tag :strong, capitalize(status)
      end
    else
      content_tag :span, capitalize(status), class: 'badge text-uppercase badge-danger' do
        content_tag :strong, capitalize(status)
      end
    end
  end

  def upcase(string)
    string.upcase
  end

  def format_class(klass)
    klass.class.name
  end

  def format_status(status)
    capitalize(status)
  end

  def format_enum(val)
    val.to_s.humanize if val.present?
  end

  def day_count(val)
    if val == 1
      "#{val} day"
    else
      "#{val} days"
    end
  end

  def percentage(number, precision: 0)
    if number
      [number_with_precision(number, precision: precision), '%'].join
    end
  end

  def capitalize(text)
    text.to_s.humanize if text
  end

  def format_currency(amount, symbol: nil, precision: 0, plus_if_positive: false, show_symbol: true, floor: false)
    [amount > 0 && plus_if_positive ? '+' : nil, amount < 0 ? '-' : nil, show_symbol ? (symbol || '₹') : nil, number_with_precision(floor ? amount.abs.floor : amount.abs, :precision => precision, delimiter: ',')].join if amount.present?
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
    ['#', id].join if id.present?
  end

  def format_date(date, format = :long)
    if date.present?
      date.strftime("%e %b, %Y %H:%M")
    end
  end

  def format_num(num, precision = 0)
    number_with_precision(num, precision: precision)
  end

  def format_int(num)
    num.to_int
  end
end