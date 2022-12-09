# frozen_string_literal: true

class Customers::CustomerProductPolicy < Customers::ApplicationPolicy
  def generate_all?
    true
  end

  def most_ordered_products?
    contact.customer_products.exists?
  end

  def index?
    current_company.present?
  end

  def online_orders?
    contact.customer_products.exists?
  end

  def current_company_has_products?
    current_company.customer_products.exists?
  end

  def product_details?
    true
  end
end
