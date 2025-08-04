module ContentFormattingHelper
  # Format content with markdown-like syntax, hashtags, and user mentions
  def format_content(content)
    return '' if content.blank?

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

  # Extract hashtags from content
  def extract_hashtags(content)
    return [] if content.blank?
    
    content.scan(/(^|\s)#([a-zA-Z_][\w]*)/m).map { |match| match[1].downcase }.uniq
  end

  # Extract mentioned usernames
  def extract_mentioned_usernames(content)
    return [] if content.blank?
    
    content.scan(/(^|\s)@([a-zA-Z0-9_]+)/m).map { |match| match[1] }
  end

  # Check if content contains links
  def contains_links?(content)
    return false if content.blank?
    
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

    content.match?(url_regex)
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
        "#{prefix}#{link_to("@#{username}", user_path(user), class: 'user-mention')}"
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
