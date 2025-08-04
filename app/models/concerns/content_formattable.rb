module ContentFormattable
  extend ActiveSupport::Concern

  def content_html
    # Simple markdown-like formatting for now
    # Replace **text** with <strong>text</strong>
    # Replace *text* with <em>text</em>
    # Replace `code` with <code>code</code>
    # Replace #hashtags with styled hashtags
    # Replace @username with user mentions
    # Replace newlines with <br> tags
    formatted = ERB::Util.html_escape(content)

    # Apply formatting transformations
    formatted = apply_bold_formatting(formatted)
    formatted = apply_italic_formatting(formatted)
    formatted = apply_code_formatting(formatted)
    formatted = apply_user_mentions(formatted)
    formatted = apply_hashtag_formatting(formatted)
    formatted = apply_newline_formatting(formatted)

    formatted.html_safe
  end

  def hashtags
    # Extract hashtags from content
    content.scan(/(^|\s)#([a-zA-Z_][\w]*)/m).map { |match| match[1].downcase }.uniq
  end

  def mentioned_users
    # Extract mentioned usernames from content and return actual User objects
    usernames = content.scan(/(^|\s)@([a-zA-Z0-9_]+)/m).map { |match| match[1] }
    User.where(username: usernames)
  end

  private

  def apply_bold_formatting(text)
    text.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
  end

  def apply_italic_formatting(text)
    text.gsub(/\*(.+?)\*/, '<em>\1</em>')
  end

  def apply_code_formatting(text)
    text.gsub(/`(.+?)`/, '<code>\1</code>')
  end

  def apply_user_mentions(text)
    # User mentions - match @ followed by username characters
    # Only create links for existing users
    text.gsub(/(^|\s)@([a-zA-Z0-9_]+)/m) do |match|
      prefix = $1
      username = $2
      user = User.find_by(username: username)
      if user
        "#{prefix}<a href=\"/users/#{user.username}\" class=\"user-mention\">@#{username}</a>"
      else
        match # Keep original text if user doesn't exist
      end
    end
  end

  def apply_hashtag_formatting(text)
    # Hashtags - match # followed by word characters (letters, numbers, underscore)
    # Avoid matching at the start of HTML tags or after numbers
    text.gsub(/(^|\s)#([a-zA-Z_][\w]*)/m) do |match|
      prefix = $1
      hashtag = $2
      "#{prefix}<span class=\"hashtag\" data-hashtag=\"#{hashtag}\">##{hashtag}</span>"
    end
  end

  def apply_newline_formatting(text)
    # Convert newlines to <br> tags
    text.gsub("\n", "<br>")
  end
end
