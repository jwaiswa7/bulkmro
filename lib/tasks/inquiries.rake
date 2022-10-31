namespace :inquiries do 
    
    desc 'Update commercial_terms_and_conditions of inquiries'
    task update_commercial_terms_and_conditions: :environment do 
        Inquiry.update_all(commercial_terms_and_conditions: [
          '1. Cost does not include any additional certification if required as per Indian regulations.',
          '2. Any errors in quotation including HSN codes, GST Tax rates must be notified before placing order.',
          '3. Order once placed cannot be changed.',
          '4. Bulk MRO does not accept any financial penalties for late deliveries.',
          '5. Warranties are applicable as per OEM\'s Standard warranty only.',
          '6. Warranty against manufacturing defects only. Damages due to mishandling and wear and tear are not covered. In case of a warranty claim, the manufacturer\'s decision will be considered final.'
      ].join("\r\n"))
    end
end