module SpamProtectable
  extend ActiveSupport::Concern

  included do
    validate :anti_spam_validation, on: :create
  end

  private

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

    spam_reasons = detect_spam_reasons(last_comment)

    # Apply spam protection if any rules matched
    if spam_reasons.any?
      time_left = (last_comment.created_at + 5.minutes - Time.current).to_i
      if time_left > 0
        errors.add(:base, I18n.t("comments.spam_protection", seconds: time_left))
      end
    end
  end

  def detect_spam_reasons(last_comment)
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

    spam_reasons
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
