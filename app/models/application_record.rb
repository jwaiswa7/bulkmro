class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_paper_trail
  include PgSearch
  include Hashid::Rails

  scope :latest, -> { order(:created_at => :desc) }
  scope :earliest, -> { order(:created_at => :asc) }
  scope :today, -> { where("DATE(#{self.model_name.collection}.created_at) = ?", Date.today) }
  scope :yesterday, -> { where("DATE(#{self.model_name.collection}.created_at) = ?", Date.today - 1) }
  scope :tomorrow, -> { where("DATE(#{self.model_name.collection}.created_at) = ?", Date.today + 1) }
  scope :before_datetime, -> (time) { where('created_at < ?', time) }
  scope :after_datetime, -> (time) { where('created_at >= ?', time) }
  scope :as_of, -> (time) { where('created_at < ?', time) }
  scope :except_object, -> (obj) { where.not(:id => obj.id) }
  scope :except_objects, -> (objs) { where.not("#{self.model_name.collection}.id IN (?)", objs.map(&:id)) }
  scope :persisted, -> { where "#{self.model_name.collection}.id IS NOT NULL" }

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
