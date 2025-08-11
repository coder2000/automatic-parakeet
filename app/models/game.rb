# == Schema Information
#
# Table name: games
#
#  id                :bigint           not null, primary key
#  adult_content     :boolean          default(FALSE)
#  author            :string
#  description       :text             not null
#  indiepad          :boolean          default(FALSE)
#  long_description  :text
#  mobile            :boolean          default(FALSE), not null
#  name              :string           not null
#  rating_abs        :float            default(0.0), not null
#  rating_avg        :float            default(0.0), not null
#  rating_count      :integer          default(0), not null
#  release_type      :integer          default("complete"), not null
#  screenshots_count :integer          default(0), not null
#  slug              :string           not null
#  videos_count      :integer          default(0), not null
#  website           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cover_image_id    :bigint
#  genre_id          :bigint
#  tool_id           :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_games_on_author             (author)
#  index_games_on_cover_image_id     (cover_image_id)
#  index_games_on_genre_id           (genre_id)
#  index_games_on_name_and_author    (name,author) UNIQUE
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
  include Pointable
  include MediaManageable

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
  has_many :game_languages, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Polymorphic media association
  has_many :media, as: :mediable, dependent: :destroy
  has_many :screenshots, -> { where(media_type: :screenshot).ordered }, as: :mediable, class_name: "Medium"
  has_many :videos, -> { where(media_type: :video).ordered }, as: :mediable, class_name: "Medium"

  # Cover image association
  belongs_to :cover_image, class_name: "Medium", optional: true

  # Nested attributes
  accepts_nested_attributes_for :download_links, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :media, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :game_languages, allow_destroy: true, reject_if: :all_blank

  extend FriendlyId
  friendly_id :name, use: :slugged

  # Validations
  validates :name, length: {maximum: 30}, presence: true
  validates :author, length: {maximum: 30}, presence: true
  validates :description, presence: true, length: {minimum: 20, maximum: 380}
  validates :long_description, length: {maximum: 2000}, allow_blank: true
  validates :download_links, length: {in: 1..10}
  validates :name, uniqueness: {scope: :author}

  validate :must_have_at_least_one_game_language

  validate :user_daily_game_upload_limit, on: :create

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

  def created_since?(days)
    created_at >= days.days.ago
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

  def must_have_at_least_one_game_language
    errors.add(:game_languages, "must have at least one") if game_languages.empty?
  end

  def user_daily_game_upload_limit
    return unless user_id
    today_count = Game.where(user_id: user_id).where("created_at >= ? AND created_at <= ?", Time.zone.now.beginning_of_day, Time.zone.now.end_of_day).count
    if today_count >= 2
      errors.add(:base, "You can only upload 2 games per day.")
    end
  end

  # Override from Pointable concern to enable point awarding for games
  def should_award_creation_points?
    true
  end

  def slug_candidates
    [
      :name,
      [:name, :name_sequence]
    ]
  end

  def name_sequence
    slug = name.to_param
    # Use parameter binding and sanitize the slug to avoid SQL injection / wildcard issues
    safe_slug = ActiveRecord::Base.sanitize_sql_like(slug)
    sequence = Game.where("slug ILIKE ?", "#{safe_slug}-%").count + 2
    "#{slug}-#{sequence}"
  end
end
