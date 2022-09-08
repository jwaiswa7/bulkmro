namespace :customer_product do 
    
    desc 'Publishes all the customer products'
    task publish_all: :environment do 
        CustomerProduct.in_batches.update_all(published: true)
        CustomerProductsIndex.import
    end
    
    desc 'Un published all the customer products'
    task unpublish_all: :environment do 
        CustomerProduct.in_batches.update_all(published: false)
        CustomerProductsIndex.import
    end
end