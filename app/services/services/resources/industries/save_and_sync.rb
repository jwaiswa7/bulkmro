# frozen_string_literal: true

class Services::Resources::Industries::SaveAndSync < Services::Shared::BaseService
  def initialize(industry)
    @industry = industry
  end

  def call
    if industry.save
      perform_later(industry)
    end
  end

  def call_later
    if industry.remote_uid.present?
      ::Resources::Industry.update(industry.remote_uid, industry)
    else
      remote_uid = ::Resources::Industry.create(industry)
      industry.update_attributes(remote_uid: remote_uid) if remote_uid.present?
    end
  end

  attr_accessor :industry
end
