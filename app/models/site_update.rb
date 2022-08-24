class SiteUpdate < ApplicationRecord
    has_one_attached :attachment
    validates :attachment, presence: true
    validates :attachment, file_content_type: { allow: ['text/csv'],message: "Please Check File Format"}
end
