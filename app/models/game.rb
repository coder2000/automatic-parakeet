# == Schema Information
#
# Table name: games
#
#  id            :bigint           not null, primary key
#  adult_content :boolean          default(FALSE)
#  description   :text             not null
#  name          :string           not null
#  rating_abs    :float            default(0.0), not null
#  rating_avg    :float            default(0.0), not null
#  rating_count  :integer          default(0), not null
#  release_type  :integer          default("complete"), not null
#  slug          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  genre_id      :bigint
#  tool_id       :bigint
#  user_id       :bigint
#
# Indexes
#
#  index_games_on_genre_id  (genre_id)
#  index_games_on_tool_id   (tool_id)
#  index_games_on_user_id   (user_id)
#
class Game < ApplicationRecord
  enum :release_type, {complete: 0, demo: 1, minigame: 2}

  # Associations
  belongs_to :user
  belongs_to :genre
  belongs_to :tool

  has_many :download_links, dependent: :destroy
  has_many :stats, dependent: :destroy
  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity", dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :followings, dependent: :destroy
  has_many :followers, through: :followings, source: :user

  # Nested attributes
  accepts_nested_attributes_for :download_links, allow_destroy: true, reject_if: :all_blank

  extend FriendlyId
  friendly_id :name, use: :slugged

  # Validations
  validates :name, presence: true
  validates :description, presence: true

  # Helper methods
  def release_type_humanized
    release_type.humanize
  end

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[name description adult_content rating_abs rating_avg rating_count release_type slug created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[user genre tool download_links activities ratings followings followers]
  end
end
