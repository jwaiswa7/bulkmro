class Resources::Project < Resources::ApplicationResource

  def self.to_remote(record)

    return {
        Code: record.id,
        Name: "New project #Inquiry #{record.id}" #record.subject
    }
  end
end