# == Schema Information
#
# Table name: games
#
#  id                :bigint           not null, primary key
#  adult_content     :boolean          default(FALSE)
#  description       :text             not null
#  name              :string           not null
#  rating_abs        :float            default(0.0), not null
#  rating_avg        :float            default(0.0), not null
#  rating_count      :integer          default(0), not null
#  release_type      :integer          default("complete"), not null
#  screenshots_count :integer          default(0), not null
#  slug              :string           not null
#  videos_count      :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cover_image_id    :bigint
#  genre_id          :bigint
#  tool_id           :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_games_on_cover_image_id     (cover_image_id)
#  index_games_on_genre_id           (genre_id)
#  index_games_on_screenshots_count  (screenshots_count)
#  index_games_on_tool_id            (tool_id)
#  index_games_on_user_id            (user_id)
#  index_games_on_videos_count       (videos_count)
#
# Foreign Keys
#
#  fk_rails_...  (cover_image_id => media.id)
#
class Game < ApplicationRecord
  enum :release_type, {complete: 0, demo: 1, minigame: 2}

  # Callbacks for point calculation
  after_create :award_creation_points
  after_destroy :remove_creation_points

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
  has_many :game_languages, dependent: :destroy

  # Polymorphic media association
  has_many :media, as: :mediable, dependent: :destroy
  has_many :screenshots, -> { where(media_type: "screenshot").ordered }, as: :mediable, class_name: "Medium"
  has_many :videos, -> { where(media_type: "video").ordered }, as: :mediable, class_name: "Medium"

  # Cover image association
  belongs_to :cover_image, class_name: "Medium", optional: true

  # Nested attributes
  accepts_nested_attributes_for :download_links, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :media, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :game_languages, allow_destroy: true, reject_if: :all_blank

  extend FriendlyId
  friendly_id :name, use: :slugged

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validate :media_limits
  validate :cover_image_must_be_screenshot

  # Helper methods
  def release_type_humanized
    release_type.humanize
  end
  
  def language_codes
    game_languages.pluck(:language_code)
  end
  
  def language_names
    game_languages.map(&:language_name)
  end
  
  def supports_language?(language_code)
    game_languages.exists?(language_code: language_code.to_s)
  end

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[name description adult_content rating_abs rating_avg rating_count release_type slug created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[user genre tool download_links activities ratings followings followers]
  end

  private

  def media_limits
    # Use counter cache for existing records, count new ones manually
    screenshot_count = screenshots_count || 0
    video_count = videos_count || 0

    # Add counts from new records being added (not yet persisted)
    media.each do |m|
      next if m.persisted? || m.marked_for_destruction?

      if m.media_type == "screenshot"
        screenshot_count += 1
      elsif m.media_type == "video"
        video_count += 1
      end
    end

    if screenshot_count > 6
      errors.add(:media, "can't have more than 6 screenshots")
    end

    if video_count > 3
      errors.add(:media, "can't have more than 3 videos")
    end
  end

  def cover_image_must_be_screenshot
    return unless cover_image.present?

    unless cover_image.screenshot?
      errors.add(:cover_image, "must be a screenshot")
    end

    unless cover_image.mediable == self
      errors.add(:cover_image, "must belong to this game")
    end
  end

  def award_creation_points
    PointCalculator.award_points(user, :create_game)
  end

  def remove_creation_points
    PointCalculator.remove_points(user, :create_game)
  end
end
