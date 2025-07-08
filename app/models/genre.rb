# == Schema Information
#
# Table name: genres
#
#  id         :bigint           not null, primary key
#  key        :string           default(""), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_genres_on_key   (key) UNIQUE
#  index_genres_on_name  (name) UNIQUE
#
class Genre < ApplicationRecord
  has_many :games, dependent: nil

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true

  # Returns the translated genre name using I18n
  def translated_name
    I18n.t("genres.names.#{key}", default: name)
  end

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[name key created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[games]
  end
end
