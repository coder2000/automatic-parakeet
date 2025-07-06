# == Schema Information
#
# Table name: platforms
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_platforms_on_name  (name) UNIQUE
#  index_platforms_on_slug  (slug) UNIQUE
#
class Platform < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_and_belongs_to_many :download_links

  validates :name, presence: true, uniqueness: true
end
