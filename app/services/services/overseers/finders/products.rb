class Services::Overseers::Finders::Products < Services::Overseers::Finders::BaseFinder

  def call
    call_base
  end

  def model_klass
    Product
  end

end