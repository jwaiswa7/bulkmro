namespace :activities do 
    desc 'update all status_updated_at in activities'
    task update_status_updated_at: :environment do 
        Chewy.strategy(:bypass) do
            Activity.all.each do | activity |
                activity.update_attributes(status_updated_at: activity&.updated_at)
                activity.save!
            end
        end
    end
end