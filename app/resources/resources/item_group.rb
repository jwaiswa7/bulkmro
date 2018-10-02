class Resources::ItemGroup < Resources::ApplicationResource

  def self.identifier
    :Number
  end

  def self.to_remote(record)
    params = {
        GroupName: record.name[0..19]
    }

    if record.is_service?
      params[:ItemClass] = "itcService"
      params[:InventorySystem] = "bis_MovingAverage"
    end
    params
  end

end