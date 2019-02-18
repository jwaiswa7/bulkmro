# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_paper_trail
  include PgSearch
  include Hashid::Rails

  belongs_to :created_by, class_name: 'Overseer', required: false

  scope :latest, -> { order(created_at: :desc) }
  scope :latest_record, -> { latest.first }
  scope :earliest, -> { order(created_at: :asc) }
  scope :today, -> { where("DATE(#{model_name.collection}.created_at) = ?", Date.today) }
  scope :updated_today, -> { where("DATE(#{model_name.collection}.updated_at) = ?", Date.today) }
  scope :yesterday, -> { where("DATE(#{model_name.collection}.created_at) = ?", Date.today - 1) }
  scope :tomorrow, -> { where("DATE(#{model_name.collection}.created_at) = ?", Date.today + 1) }
  scope :before_datetime, ->(time) { where('created_at < ?', time) }
  scope :after_datetime, ->(time) { where('created_at >= ?', time) }
  scope :as_of, ->(time) { where('created_at < ?', time) }
  scope :except_object, ->(obj) { where.not(id: obj.id) if obj.present? }
  scope :except_objects, ->(objs) { where.not("#{model_name.collection}.id IN (?)", objs.pluck(:id)) if objs.present? }
  scope :persisted, -> { where "#{model_name.collection}.id IS NOT NULL" }
  scope :legacy, -> { where.not(legacy_id: nil) }
  scope :not_legacy, -> { where(legacy_id: nil) }
  scope :between_month_for, ->(datetime) { where(created_at: datetime.beginning_of_month..datetime.end_of_month) }
  scope :alphabetical, -> { order(first_name: :asc) }

  def legacy?
    legacy_id.present?
  end

  def not_legacy?
    !legacy?
  end

  def next
    where('id > ?', id).order(id: :asc).first || first
  end

  def previous
    where('id < ?', id).order(id: :desc).first || last
  end

  def to_s
    try(:name) || try(:full_name) || try(:description) || "#{self.class} ##{id}"
  end

  def created_date
    created_at.strftime('%F') if created_at.present?
  end

  def updated_date
    updated_at.strftime('%F') if updated_at.present?
  end

  def self.execute_sql(*sql_array)
    connection.execute(sanitize_sql_array(sql_array))
  end
end
