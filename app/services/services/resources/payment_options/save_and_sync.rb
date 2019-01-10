class Services::Resources::PaymentOptions::SaveAndSync < Services::Shared::BaseService

  def initialize(payment_option)
    @payment_option = payment_option
  end

  def call
    if payment_option.save
      perform_later(payment_option)
    end
  end

  def call_later
    if payment_option.persisted?
      if payment_option.remote_uid.present?
        ::Resources::PaymentTermsType.update(payment_option.remote_uid, payment_option)
      else
        payment_option.update_attributes(:remote_uid => ::Resources::PaymentTermsType.create(payment_option))
      end
    end
  end

  attr_accessor :payment_option
end