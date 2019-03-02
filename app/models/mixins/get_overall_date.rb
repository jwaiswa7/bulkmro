# frozen_string_literal: true

module Mixins::GetOverallDate
  extend ActiveSupport::Concern

  def get_overall_date1(object, date = :supplier_delivery_date)
    new_object = object.rows.order("#{date} ASC").where("#{date} >= ?", Date.today)
    if new_object.first.send(date).present?
      new_object.first.send(date).strftime('%d-%b-%Y')
    else
      new_object.last.send(date).strftime('%d-%b-%Y')
    end
  end
end
