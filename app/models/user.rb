# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  given_name             :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locale                 :string
#  notification_count     :integer          default(0), not null
#  phone_number           :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  score                  :integer          default(0), not null
#  sign_in_count          :integer          default(0), not null
#  staff                  :boolean          default(FALSE), not null
#  surname                :string
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_locale                (locale)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Store user's preferred locale
  # Add a migration to add a `locale` column to users table if not present
  # Example: rails g migration AddLocaleToUsers locale:string

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :confirmable, :trackable

  # Associations
  has_many :games, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :followings, dependent: :destroy
  has_many :followed_games, through: :followings, source: :game
  has_many :rated_games, through: :ratings, source: :game
  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity", dependent: :destroy
  has_many :owned_activities, foreign_key: :owner_id, class_name: "PublicActivity::Activity", dependent: :destroy

  # Returns the user's preferred locale, or nil if not set
  def preferred_locale
    locale.presence
  end

  # Check if user is staff
  def staff?
    staff
  end

  # Point-related methods
  def total_points
    score
  end

  def points_from_activities
    owned_activities.where(key: "points.awarded").sum { |a| a.parameters["points"] || 0 }
  end

  def recent_point_activities(limit = 10)
    owned_activities.where(key: ["points.awarded", "points.removed"])
      .order(created_at: :desc)
      .limit(limit)
  end

  # Define searchable attributes for Ransack (excluding sensitive information)
  def self.ransackable_attributes(auth_object = nil)
    %w[given_name surname email locale notification_count score sign_in_count staff created_at updated_at confirmed_at current_sign_in_at last_sign_in_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[games]
  end
end
