# == Schema Information
#
# Table name: followings
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_followings_on_game_id  (game_id)
#  index_followings_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
class Following < ApplicationRecord
  include PublicActivity::Common

  belongs_to :user
  belongs_to :game

  validates :game_id, uniqueness: {scope: :user_id}

  # Callbacks for point calculation
  after_create :award_follow_points
  after_destroy :remove_follow_points

  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity", dependent: :destroy, inverse_of: :trackable

  # Scopes
  scope :for_user, ->(user) { where(user: user) }
  scope :for_game, ->(game) { where(game: game) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def to_s
    "#{user.email} follows #{game.name}"
  end

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[user game]
  end

  private

  def award_follow_points
    PointCalculator.award_points(user, :follow_game)
  end

  def remove_follow_points
    PointCalculator.remove_points(user, :follow_game)
  end
end
