class Services::Overseers::Finders::Inquiries < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def sort_definition
    {:inquiry_number => :desc}
  end

  def model_klass
    Inquiry
  end
end