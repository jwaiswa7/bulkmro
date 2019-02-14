module Mixins::HasMobileAndTelephone
  extend ActiveSupport::Concern

  included do
    # validates_presence_of :telephone, if: -> { :not_legacy? && self.telephone.blank?  }
    # validates_presence_of :mobile, if: -> {:not_legacy? && self.mobile.blank?}
    phony_normalize :telephone, :mobile, default_country_code: 'IN', if: :not_legacy?
    validates_plausible_phone :telephone, :mobile, allow_blank: true, if: :not_legacy?

    def phone
      self.mobile || self.telephone
    end
  end
end
