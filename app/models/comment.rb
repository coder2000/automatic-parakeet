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
  belongs_to :game
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true

  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy

  # Validations
  validates :content, presence: true, length: {minimum: 3, maximum: 1000}
  validate :parent_must_belong_to_same_game
  validate :no_deeply_nested_replies
  validate :anti_spam_validation

  # Scopes
  scope :top_level, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:created_at) }
  scope :recent, -> { order(created_at: :desc) }

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

  def anti_spam_validation
    return if user.blank? || content.blank?
    return unless new_record? # Only validate on creation

    # Get the user's last comment (within last 5 minutes to optimize query)
    last_comment = user.comments
      .where("created_at > ?", 5.minutes.ago)
      .order(created_at: :desc)
      .first

    return unless last_comment

    # Check if last comment was posted less than 2 minutes ago
    return unless last_comment.created_at > 2.minutes.ago

    spam_reasons = []

    # Rule 1: Previously posted a short comment (less than 20 characters)
    if last_comment.content.length < 20
      spam_reasons << "short_comment"
    end

    # Rule 2: Previously posted the same text
    if last_comment.content.strip.downcase == content.strip.downcase
      spam_reasons << "duplicate_content"
    end

    # Rule 3: Previously posted a link (check for URLs)
    if contains_link?(last_comment.content)
      spam_reasons << "previous_link"
    end

    # Apply spam protection if any rules matched
    if spam_reasons.any?
      time_left = (last_comment.created_at + 5.minutes - Time.current).to_i
      if time_left > 0
        errors.add(:base, I18n.t("comments.spam_protection", seconds: time_left))
      end
    end
  end

  def contains_link?(text)
    # Regular expression to detect URLs
    url_regex = %r{
      (?:https?://|www\.)     # Protocol or www
      (?:
        [-\w.]                # Domain characters
      )+
      (?:
        \.[a-zA-Z]{2,}        # TLD
      )
      (?:
        [/?#][-\w./?#@!$&'()*+,;=:%]*  # Path/query/fragment
      )?
    }x

    text.match?(url_regex)
  end
end
