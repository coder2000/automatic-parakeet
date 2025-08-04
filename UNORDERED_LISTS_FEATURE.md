# Unordered Lists Feature for Comments

## Overview

Users can now create unordered lists in their comments using markdown-like syntax. This feature extends the existing content formatting capabilities alongside hashtags, user mentions, and other markdown formatting.

## Syntax

Users can create unordered lists using either:

- **Dash syntax**: Lines starting with `-` (dash followed by space)
- **Asterisk syntax**: Lines starting with `*` (asterisk followed by space)

### Examples

```markdown
My favorite games:
- Super Mario Bros
- The Legend of Zelda
- Metroid

Things to remember:
* Save your progress frequently
* Check for updates regularly
* Join the community discord
```

## Features

### ✅ Basic List Support

- Converts lines starting with `-` or `*` to HTML `<ul>` and `<li>` elements
- Supports mixed dash and asterisk syntax within the same list
- Handles indented list items (spaces before the dash/asterisk)

### ✅ Content Integration

- **Works with other formatting**: Bold (`**text**`), italic (`*text*`), and code (`` `text` ``) formatting inside list items
- **Hashtag support**: Hashtags in list items are properly converted to clickable spans
- **User mentions**: User mentions in list items are converted to clickable links
- **Proper HTML escaping**: All content is properly escaped for security

### ✅ Smart List Management

- **Automatic list boundaries**: Lists are automatically started and closed when encountering non-list content
- **Multiple lists**: Supports multiple separate lists within the same comment
- **Empty list items**: Gracefully handles empty list items (`-` with no content)
- **Line break management**: Prevents `<br>` tags from appearing inside lists while maintaining proper spacing around lists

### ✅ Edge Case Handling

- **Validation**: Only converts lines that properly match the list pattern (dash/asterisk + space + content)
- **No false positives**: Lines like `-missing space` or `*missing space` are not converted to lists
- **Spacing preservation**: Maintains proper spacing before and after lists

## Implementation Details

### Backend (ContentFormattable Concern)

The functionality is implemented in the `ContentFormattable` concern (`app/models/concerns/content_formattable.rb`):

```ruby
def apply_unordered_lists(text)
  # Convert markdown-style unordered lists to HTML
  # Matches lines that start with - or * followed by a space
  lines = text.split("\n")
  result = []
  in_list = false

  lines.each do |line|
    # Check if line is a list item (starts with optional whitespace, then - or *, then space, then content)
    if line.match(/^\s*[-*]\s(.*)$/)
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
```

### Processing Order

Lists are processed in the correct order within the formatting pipeline:

1. HTML escaping
2. Bold formatting (`**text**`)
3. Italic formatting (`*text*`)
4. Code formatting (`` `text` ``)
5. User mentions (`@username`)
6. Hashtag formatting (`#hashtag`)
7. **Unordered lists** (`- item` / `* item`) ← NEW
8. Newline formatting (convert `\n` to `<br>`, but not inside lists)

### Helper Support

The same functionality is also available in the `ContentFormattingHelper` (`app/helpers/content_formatting_helper.rb`) for view-level usage.

## User Interface

### Form Helper Text

The helper text in comment forms has been updated to inform users about the new feature:

- **English**: `"Markdown, #hashtags, @mentions & lists supported"`
- **Spanish**: `"Markdown, #hashtags, @menciones y listas soportados"`

## Testing

Comprehensive test coverage includes:

- ✅ Basic list conversion (dash and asterisk syntax)
- ✅ Mixed syntax support
- ✅ Integration with other formatting features
- ✅ Hashtag and user mention support within lists
- ✅ Multiple lists in same comment
- ✅ Proper list boundary detection
- ✅ Empty list item handling
- ✅ Line break management
- ✅ Edge cases and validation
- ✅ Indented list support

**Test file**: `spec/models/comment_lists_spec.rb` (11 comprehensive test cases)

## Security

- All content is properly HTML-escaped before processing
- No user input is directly inserted into HTML without sanitization
- The regex pattern is restrictive and only matches intended list syntax
- Existing security measures for hashtags and user mentions remain intact

## Performance

- Minimal performance impact: Lists are processed as part of the existing formatting pipeline
- No additional database queries required
- Efficient regex matching for list detection

## Examples in Use

### Basic Lists

**Input:**

```
Great features:
- Awesome graphics
- Amazing soundtrack
- Challenging gameplay
```

**Output:**

```html
Great features:<br>
<ul>
<li>Awesome graphics</li>
<li>Amazing soundtrack</li>
<li>Challenging gameplay</li>
</ul>
```

### Lists with Other Formatting

**Input:**

```
Todo:
- Review **important** changes
- Ask @john about the #bugfix
- Test `new_feature()` function
```

**Output:**

```html
Todo:<br>
<ul>
<li>Review <strong>important</strong> changes</li>
<li>Ask <a href="/users/john" class="user-mention">@john</a> about the <span class="hashtag" data-hashtag="bugfix">#bugfix</span></li>
<li>Test <code>new_feature()</code> function</li>
</ul>
```

## Future Enhancements

Potential future improvements could include:

- Ordered lists (`1. item`, `2. item`)
- Nested lists (sub-items with additional indentation)
- Custom list styling options
- List item checkboxes (`- [ ] unchecked`, `- [x] checked`)

This feature enhances the comment system's formatting capabilities while maintaining security, performance, and compatibility with existing features.
