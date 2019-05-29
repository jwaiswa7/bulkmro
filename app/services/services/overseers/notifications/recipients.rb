class Services::Overseers::Notifications::Recipients
  class << self
    def customer_so_managers
      ['priyanka.rajpurkar@bulkmro.com', 'nilesh.desai@bulkmro.com', 'lavanya.j@bulkmro.com']
    end

    def logistics_owners
      ['dinesh.kumar@bulkmro.com']
    end

    def ar_invoice_request_notifiers
      %w(pravin.ganekar@bulkmro.com ajay.kondal@bulkmro.com shweta.jadhav@bulkmro.com)
    end
  end
end
