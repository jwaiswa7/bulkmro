class Services::Resources::Companies::UploadProductImage < Services::Shared::BaseService
    def initialize(company, images = [])
      @company = company
      @images = images
    end
    
    # Call methos will upload images to AWS
    # Once the images are uploaded, then the customer products image path will be updated with the image urls
    def call 
     "something something"
    end
end 