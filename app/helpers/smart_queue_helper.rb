# frozen_string_literal: true

module SmartQueueHelper
  def smart_queue_priority_color(priority)
    if priority >= 107
      "danger"
    elsif priority >= 104
      "primary"
    elsif priority >= 100
      "warning"
    elsif priority >= 7
      "success"
    elsif priority >= 4
      "success"
    elsif priority >= 0
      "success"
    end
  end

  def smart_queue_priority_state(priority)
    if priority >= 107
      "Extreme"
    elsif priority >= 104
      "Very High"
    elsif priority >= 100
      "High"
    elsif priority >= 7
      "Normal"
    elsif priority >= 4
      "Low"
    elsif priority >= 0
      "Very Low"
    end
  end

  def priority_helper_format_label(priority)
    format_badge(smart_queue_priority_state(priority), smart_queue_priority_color(priority))
  end
end
