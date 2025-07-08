# == Schema Information
#
# Table name: news
#
#  id         :bigint           not null, primary key
#  text       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_news_on_game_id  (game_id)
#  index_news_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
class News < ApplicationRecord
  belongs_to :game
  belongs_to :user

  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity", dependent: :destroy

  validates :text, presence: true

  # Ensure PublicActivity::Activity has trackable_id and trackable_type columns
  # for shoulda-matchers to work correctly with polymorphic associations.

  validate :cooloff_period, on: :create

  def self.last_by_user(user)
    where(user: user).order(created_at: :desc).first
  end

  def self.cooloff_interval
    NewsConfig.cooloff_interval
  end

  private

  def cooloff_period
    last_news = News.last_by_user(user)
    return unless last_news && last_news != self

    if last_news.created_at > cooloff_cutoff_time
      errors.add(:base, :cooloff, message: "Please wait before posting another news item.")
    end
  end

  def cooloff_cutoff_time
    Time.current - self.class.cooloff_interval
  end

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[text created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[game user activities]
  end
end
