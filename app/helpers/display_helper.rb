module DisplayHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper

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

  def percentage(number, precision: 0, show_symbol: true)
    if number && !number.nan? && show_symbol
      [number_with_precision(number, precision: precision), '%'].join
    else
      number_with_precision(number, precision: precision)
    end
  end

  def calculate_percentage(val1, val2, precision: 0)
    if val2 == 0
      '0%'
    else
      value = (val1.as_percentage_of(val2).to_f).round(2)
      percentage(value)
    end
  end

  def capitalize(text)
    text.to_s.humanize if text
  end

  def format_currency(amount, symbol: nil, precision: 2, plus_if_positive: false, show_symbol: true, floor: false)
    if amount.present?
      amount = amount.to_f
      [amount > 0 && plus_if_positive ? '+' : nil, amount < 0 ? '-' : nil, show_symbol ? (symbol || '₹') : nil, number_with_precision(floor ? amount.abs.floor : amount.abs, precision: precision, delimiter: ',')].join if amount.present?
    else
      '-'
    end
  end

  def conditional_link(string, url, allowed)
    if allowed
      return link_to string, url, target: '_blank'
    else
      return string
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

  def format_succinct_date(date)
    if date.present?
      # date.strftime("%e %b, %Y %H:%M")
      date.strftime('%d-%b-%y')
    else
      '-'
    end
  end

  def format_date(date)
    if date.present?
      # date.strftime("%e %b, %Y %H:%M")
      date.strftime('%d-%b-%Y')
    else
      '-'
    end
  end

  def format_date_with_time(date)
    if date.present?
      # date.strftime("%e %b, %Y %H:%M")
      date.strftime('%d-%b-%Y %H:%M')
    else
      '-'
    end
  end


  def format_date_time_meridiem(date)
    if date.present?
      date.strftime('%d-%b-%Y, %I:%M %p')
    else
      '-'
    end
  end

  def format_date_time_with_second(date)
    if date.present?
      date.strftime('%d-%b-%Y, %I:%M:%S %p')
    else
      '-'
    end
  end

  def format_date_without_time(date)
    if date.present?
      date.strftime('%d-%b-%Y')
    end
  end

  def format_date_without_time_and_date(date)
    if date.present?
      date.strftime('%b-%Y')
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

  def format_boolean(true_or_false)
    (true_or_false ? '<i class="far fa-check text-success"></i>' : '<i class="far fa-times text-danger"></i>').html_safe
  end

  def format_boolean_with_badge(status)
    (
    if status == 'complete'
      '<i class="far fa-check text-success"></i>'
    elsif status == 'partial'
      '<i class="far fa-check text-color-dark-blue"> <span class="badge badge-color-dark-blue">Partial</span></i>'
    else
      '<i class="far fa-times text-danger"></i>'
    end).html_safe
  end

  def format_boolean_label(true_or_false, verb = '')
    yes = verb ? verb : 'Yes'
    no = verb ? ['Not', verb].join(' ') : 'No'
    (true_or_false ? ['<span class="badge badge-success text-uppercase">', yes, '</span>'].join('') : ['<span class="badge badge-danger text-uppercase">', no, '</span>'].join('')).html_safe
  end

  def format_star(rating)
    star_given = rating.nil? ? 0 : number_with_precision(rating, precision: 1).to_f
    color = 'text-success'
    if star_given < 3
      color = 'text-danger'
    elsif star_given > 3 && star_given <= 4
      color = 'text-warning'
    end

    (["<i class='fas fa-star #{color}'></i>", "<span class='render-star #{color}'>", star_given, '<span/>'].join(' ')).html_safe
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

  def conditional_link(string, url, allowed)
    if allowed
      return link_to string, url, target: '_blank'
    else
      return string
    end
  end

  def url_for_image(image, fallback_url: '', check_remote: false)
    if image.present? && (check_remote == false || ActiveStorage::Blob.service.exist?(image.key))
      url_for(image)
    else
      fallback_url
    end
  end

  def chewy_indices
    Dir[[Chewy.indices_path, '/*'].join()].map do |path|
      path.gsub('.rb', '').gsub('app/chewy/', '') if !path.include? 'base_index'
    end.compact
  end

  def format_comment(comment, trimmed = false)
    render partial: 'shared/snippets/comments.html', locals: {comment: comment, trimmed: trimmed}
  end

  def attribute_boxes(data)
    render partial: 'shared/snippets/attribute_boxes.html', locals: {data: data}
  end

  def humanize(mins)
    [[60, :minutes], [24, :hours], [Float::INFINITY, :days]].map {|count, name|
      if mins > 0
        mins, n = mins.divmod(count)
        unless n.to_i == 0
          name = name.to_s.singularize if n == 1
          "#{n.to_i} #{name}"
        end

      end
    }.compact.reverse.join(' ')
  end

  def format_times_ago(time)
    [time_ago_in_words(time), 'ago'].join(' ').html_safe
  end

  def format_due_distance(due_date)
    current_date = Date.today
    due_in_days = (due_date - current_date).to_i

    if due_in_days < 0
      due_string = 'Overdue'
    elsif due_in_days == 0
      due_string = 'Due Today'
      return due_badge(due_in_days, due_string)
    else
      due_string = 'Due In'
    end

    due_badge(due_in_days, [due_string, distance_of_time_in_words(current_date, due_date)].join(' '))
  end

  def current_user
    current_overseer
  end

  def format_percent_of(d, n, precision: 0, plus_if_positive: false, show_symbol: true, floor: false)
    precentage = (d.to_f / n.to_f * 100.0)
    if d.present? && n.present?
      [precentage > 0 && plus_if_positive ? '+' : nil, precentage < 0 ? '-' : nil, number_with_precision(floor ? precentage.abs.floor : precentage.abs, precision: precision), show_symbol ? ('%') : nil].join
    else
      0
    end
  end

  def format_review_document(company_review)
    if company_review.rateable_type == 'PoRequest'
      row_action_button(overseers_po_request_path(company_review.rateable), 'file-invoice', 'View PO Request', 'success', :_blank)
    elsif company_review.rateable_type == 'InvoiceRequest'
      row_action_button(overseers_invoice_request_path(company_review.rateable), 'dollar-sign', 'View GRPO Request', 'success', :_blank)
    end
  end

  def product_line_item
    if self.rows.count == 1 && self.rows.first.product.is_kit
      content_tag(:div, content_tag(:strong, "#{self.rows.first.product.kit.kit_product_rows.count}") + ' kit line item(s)')
    else
      content_tag(:div, content_tag(:strong, "#{self.rows.count}") + ' line item(s)')
    end
  end

  def is_authorized(model, action)
    authorised = false
    if current_overseer.is_super_admin
      authorised = true
    else
      action_name = action if action.present?
      allowed_resources = ActiveSupport::JSON.decode(current_overseer.acl_resources)
      resource_ids = get_acl_resource_ids

      if model.is_a?(ActiveRecord::Base)
        resource_model = model.class.name.underscore.downcase
      elsif model.is_a?(ActiveRecord::Relation)
        resource_model = model.klass.name.underscore.downcase
      else
        resource_model = model.to_s.gsub(':', '')
      end

      if resource_ids[resource_model].blank? || resource_ids[resource_model][action_name].blank?
        authorised = false
      elsif allowed_resources.include? resource_ids[resource_model][action_name].to_s
        authorised = true
      end
    end
    authorised
  end

  def get_acl_resource_ids
    Rails.cache.fetch('acl_resource_ids', expires_in: 3.hours) do
      AclResource.acl_resource_ids
    end
  end
end
