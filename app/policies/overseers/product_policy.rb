# frozen_string_literal: true

class Overseers::ProductPolicy < Overseers::ApplicationPolicy
  def new?
    cataloging? || admin?
  end

  def comments?
    record.persisted?
  end

  def show?
    super || logistics?
  end

  def pending?
    cataloging? || admin?
  end

  def approve?
    pending? && record.not_approved? && !record.rejected?
  end

  def reject?
    approve?
  end

  def merge?
    approve?
  end

  def customer_bp_catalog?
    index?
  end

  def best_prices_and_supplier_bp_catalog?
    index?
  end

  def sku_purchase_history?
    index? && record.inquiry_products.any?
  end

  def resync_inventory?
    true
  end

  def resync?
    record.approved? && record.not_synced?
  end

  def export_all?
    # allow_export? || ['priyanka.rajpurkar@bulkmro.com', 'subrata.baruah@bulkmro.com'].include?(overseer.email)
    allow_product_export?
  end


  def service_autocomplete?
    index?
  end
  def autocomplete_mpn?
    index?
  end

  def non_kit_autocomplete?
    edit?
  end

  def autocomplete_suppliers?
    true
  end

  def get_product_details?
    true
  end

  def suggestion?
    true
  end
end
