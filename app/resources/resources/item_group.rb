class Resources::ItemGroup < Resources::ApplicationResource
  def self.identifier
    :Number
  end

  def self.to_remote(record)
    params = {
        GroupName: record.name[0..19]
    }

    params.merge!(
      ItemClass: 'itcService',
      InventorySystem: 'bis_MovingAverage'
                  ) if record.is_service?

    params
  end
end
