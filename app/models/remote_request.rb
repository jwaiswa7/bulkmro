class RemoteRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsARequest

  scope :recent_failed, -> { select(:subject_type,:subject_id, "Max(created_at) as MaxDate").group(:subject_type,:subject_id).failed }

  scope :todays_recent_failed, -> { select(:subject_type,:subject_id, "Max(created_at) as MaxDate").group(:subject_type,:subject_id).failed.where(:created_at => Date.yesterday.beginning_of_day..Date.yesterday.end_of_day) }

  def latest_status
    RemoteRequest.where(:subject_type => self.subject_type).where(:subject_id => self.subject_id).order(:created_at).last.status
  end

  pg_search_scope :locate, :against => [:url], :associated_against => {}, :using => { :tsearch => { :prefix => true } }

end
