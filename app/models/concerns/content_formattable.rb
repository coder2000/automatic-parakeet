module ContentFormattable
  extend ActiveSupport::Concern

  def content_html
    # Simple markdown-like formatting for now
    # Replace **text** with <strong>text</strong>
    # Replace *text* with <em>text</em>
    # Replace `code` with <code>code</code>
    # Replace ||spoiler|| with spoiler text
    # Replace #hashtags with styled hashtags
    # Replace @username with user mentions
    # Replace - item or * item with unordered lists
    # Replace newlines with <br> tags
    formatted = ERB::Util.html_escape(content)

    # Apply formatting transformations
    formatted = apply_bold_formatting(formatted)
    formatted = apply_italic_formatting(formatted)
    formatted = apply_code_formatting(formatted)
    formatted = apply_user_mentions(formatted)
    formatted = apply_hashtag_formatting(formatted)
    formatted = apply_spoiler_formatting(formatted)
    formatted = apply_unordered_lists(formatted)
    formatted = apply_newline_formatting(formatted)

    formatted.html_safe
  end

  def hashtags
    # Extract hashtags from content
    content.scan(/(^|\s)#([a-zA-Z_][\w]*)/m).map { |match| match[1].downcase }.uniq
  end

  def mentioned_users
    # Extract mentioned usernames from content and return actual User objects
    usernames = content.scan(/(^|\s|\|\|)@([a-zA-Z0-9_]+)/m).map { |match| match[1] }
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

  def apply_spoiler_formatting(text)
    # Spoiler text - match ||text|| for spoiler content (including empty and multiline)
    text.gsub(/\|\|(.*?)\|\|/m, '<span class="spoiler" title="Click to reveal spoiler">\1</span>')
  end

  def apply_user_mentions(text)
    # User mentions - match @ followed by username characters
    # Only create links for existing users
    # Match after start of line, whitespace, or spoiler opening tags
    text.gsub(/(^|\s|\|\|)@([a-zA-Z0-9_]+)/m) do |match|
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

  def apply_unordered_lists(text)
    # Convert markdown-style unordered lists to HTML
    # Matches lines that start with - or * followed by a space (at start of line, ignoring leading whitespace)
    lines = text.split("\n")
    result = []
    in_list = false

    lines.each do |line|
      # Check if line is a list item (starts with optional whitespace, then - or *, then space, then content)
      if line =~ /^\s*[-*]\s(.*)$/
        list_content = $1

        # If not already in a list, start one
        unless in_list
          result << "<ul>"
          in_list = true
        end

        result << "<li>#{list_content}</li>"
      else
        # If we were in a list and this line is not a list item, close the list
        if in_list
          result << "</ul>"
          in_list = false
        end

        result << line
      end
    end

    # Close list if we end while still in one
    if in_list
      result << "</ul>"
    end

    result.join("\n")
  end

  def apply_newline_formatting(text)
    # Convert newlines to <br> tags, but avoid adding <br> inside lists
    # Split by lines and process each
    lines = text.split("\n")
    result = []

    lines.each_with_index do |line, index|
      result << line

      # Add <br> unless:
      # - This is the last line
      # - The line is a list-related tag (<ul>, </ul>, <li>, </li>)
      # - The next line is a list-related tag
      next_line = lines[index + 1]

      if index != lines.length - 1 &&
          !line.match?(/^\s*<\/?(?:ul|li)>/) &&
          !(next_line && next_line.match?(/^\s*<\/?(?:ul|li)>/))
        result << "<br>"
      end
    end

    result.join("")
  end
end
