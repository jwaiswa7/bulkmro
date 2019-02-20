class Services::Resources::Kits::SaveAndSync < Services::Shared::BaseService
  def initialize(kit)
    @kit = kit
  end

  def call
    if kit.save
      perform_later(kit)
    end
  end

  def call_later
    if kit.persisted?
      remote_uid = ::Resources::ProductTree.custom_find(kit.product.sku)
      remote_uid.present? ? kit.update_attributes(remote_uid: remote_uid) : kit.update_attributes(remote_uid: nil)

      kit.product.save_and_sync

      kit.kit_product_rows.each do |kit_product|
        if kit_product.product.remote_uid.blank?
          kit_product.product.save_and_sync
        end
      end

      if kit.remote_uid.present?
        ::Resources::ProductTree.update(kit.remote_uid, kit, quotes: true)
      else
        kit.update_attributes(remote_uid: ::Resources::ProductTree.create(kit))
      end
    end
  end

  attr_accessor :kit
end
