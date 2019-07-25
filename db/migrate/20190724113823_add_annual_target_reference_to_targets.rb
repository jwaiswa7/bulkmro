class AddAnnualTargetReferenceToTargets < ActiveRecord::Migration[5.2]
  def change
    add_reference :targets ,:annual_target, foreign_key: true
  end
end
