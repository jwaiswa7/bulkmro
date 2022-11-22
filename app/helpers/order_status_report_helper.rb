module OrderStatusReportHelper 

    def disable_report_select(current_overseer)
      if current_overseer.present?
        true if current_overseer.inside_sales_executive? || current_overseer.outside_sales_executive?
      end
    end

    def selected_procurement_specialist(current_overseer,params)
      if current_overseer.present? && current_overseer.inside_sales_executive? 
        return current_overseer.id
      end

      params['customer_order_status_report'].present? && params['customer_order_status_report']['procurement_specialist'].present? ? params['customer_order_status_report']['procurement_specialist'].to_i : ''
    end

    def selected_outside_sales_owner(current_overseer,params)
      if current_overseer.present? && current_overseer.outside_sales_executive? 
        return current_overseer.id
      end

      params['customer_order_status_report'].present? && params['customer_order_status_report']['outside_sales_owner'].present? ? params['customer_order_status_report']['outside_sales_owner'].to_i : ''
    end
end