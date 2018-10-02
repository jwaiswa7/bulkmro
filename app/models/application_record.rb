class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_paper_trail
  include PgSearch
  include Hashid::Rails

  belongs_to :created_by, class_name: 'Overseer', required: false

  scope :latest, -> { order(:created_at => :desc) }
  scope :latest_record, -> { latest.first }
  scope :earliest, -> { order(:created_at => :asc) }
  scope :today, -> { where("DATE(#{self.model_name.collection}.created_at) = ?", Date.today) }
  scope :yesterday, -> { where("DATE(#{self.model_name.collection}.created_at) = ?", Date.today - 1) }
  scope :tomorrow, -> { where("DATE(#{self.model_name.collection}.created_at) = ?", Date.today + 1) }
  scope :before_datetime, -> (time) { where('created_at < ?', time) }
  scope :after_datetime, -> (time) { where('created_at >= ?', time) }
  scope :as_of, -> (time) { where('created_at < ?', time) }
  scope :except_object, -> (obj) { where.not(:id => obj.id) if obj.present? }
  scope :except_objects, -> (objs) { where.not("#{self.model_name.collection}.id IN (?)", objs.pluck(:id)) if objs.present? }
  scope :persisted, -> { where "#{self.model_name.collection}.id IS NOT NULL" }
  scope :legacy, -> { where.not(:legacy_id => nil) }
  scope :not_legacy, -> { where(:legacy_id => nil) }

  def legacy?
    self.legacy_id.present?
  end

  def not_legacy?
    !legacy?
  end

  def next
    self.where('id > ?', id).order(id: :asc).first || self.first
  end

  def previous
    self.where('id < ?', id).order(id: :desc).first || self.last
  end

  def to_s
    try(:name) || try(:full_name) || try(:description) || "#{self.class.to_s} ##{self.id}"
  end
end
