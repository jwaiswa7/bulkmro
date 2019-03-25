module FilteringHelper
  def filtered_path(path, filters)
    # Set the #! for dynamic filter changes by window.hasher
    path += '#!'
    for f in filters
      path += [f, '&'].join('')
    end

    # Remove the extra &
    path.chop
  end

  def filter_by_value(column, text, value)
    v = value ? ['|', value].join('') : ''
    [column, '=', text, v].join('')
  end

  def filter_by_date(column, from, to)
    [column, '=', from, '~', to].join('')
  end

  def filter_by_monthrange(column, date)
    from = date.to_date.beginning_of_month
    to = date.to_date.end_of_month

    filter_by_date(column, from, to)
  end
end
