class Customers::AddressesController < Customers::BaseController
  
    def autocomplete      
      @addresses = ApplyParams.to(Address.all.includes(:state), params)
      authorize @addresses
    end 
    
end
  