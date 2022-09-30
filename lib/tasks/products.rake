namespace :products do 
    
    desc 'Re Sync all Products with SAP'
    task re_sync_with_sap: :environment do 
        Chewy.strategy(:bypass) do
            Product.approved.active.each do |product|
                product.save_and_sync
            end
        end
    end
    
end