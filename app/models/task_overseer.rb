class TaskOverseer < ApplicationRecord

  belongs_to :overseer
  belongs_to :task

  validates_presence_of :overseer, :task
  validates_uniqueness_of :overseer, scope: :task


end
