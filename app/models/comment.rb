# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  parent_id  :bigint
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_game_id                   (game_id)
#  index_comments_on_game_id_and_created_at    (game_id,created_at)
#  index_comments_on_parent_id                 (parent_id)
#  index_comments_on_parent_id_and_created_at  (parent_id,created_at)
#  index_comments_on_user_id                   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (parent_id => comments.id)
#  fk_rails_...  (user_id => users.id)
#
class Comment < ApplicationRecord
  include ContentFormattable
  include SpamProtectable
  include Pointable

  belongs_to :game
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true

  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy

  # Validations
  validates :content, presence: true, length: {minimum: 20, maximum: 500}
  validate :parent_must_belong_to_same_game
  validate :no_deeply_nested_replies

  # Scopes
  scope :top_level, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:created_at) }
  scope :recent, -> { order(created_at: :desc) }
  scope :with_hashtag, ->(hashtag) {
    return none if hashtag.blank?
    # Remove # if present and normalize to lowercase
    tag = hashtag.gsub(/^#/, "").downcase
    where("LOWER(content) ~ ?", "(^|[^\\w])##{Regexp.escape(tag)}([^\\w]|$)")
  }

  # Methods
  def top_level?
    parent_id.nil?
  end

  def reply?
    parent_id.present?
  end

  def can_be_replied_to?
    top_level? # Only allow one level of nesting
  end

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[content created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[user game parent replies]
  end

  private

  def parent_must_belong_to_same_game
    return unless parent.present?

    if parent.game_id != game_id
      errors.add(:parent, "must belong to the same game")
    end
  end

  def no_deeply_nested_replies
    return unless parent.present?

    if parent.parent.present?
      errors.add(:parent, "cannot reply to a reply (only one level of nesting allowed)")
    end
  end

  # Override from Pointable concern to enable point awarding for comments
  def should_award_creation_points?
    true
  end
end
