require "rails_helper"

RSpec.describe Comment, "unordered list functionality", type: :model do
  let(:user) { create(:user) }
  let(:game) { create(:game) }

  describe "#content_html" do
    context "with unordered lists" do
      it "converts single dash list items to HTML list" do
        comment = create(:comment,
          content: "Here are some features:\n- Feature one\n- Feature two\n- Feature three",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<ul>")
        expect(html).to include("<li>Feature one</li>")
        expect(html).to include("<li>Feature two</li>")
        expect(html).to include("<li>Feature three</li>")
        expect(html).to include("</ul>")
      end

      it "converts single asterisk list items to HTML list" do
        comment = create(:comment,
          content: "Things to remember:\n* Remember this\n* And this too\n* Also this",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<ul>")
        expect(html).to include("<li>Remember this</li>")
        expect(html).to include("<li>And this too</li>")
        expect(html).to include("<li>Also this</li>")
        expect(html).to include("</ul>")
      end

      it "handles mixed dash and asterisk list items" do
        comment = create(:comment,
          content: "Mixed list:\n- First item\n* Second item\n- Third item",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<ul>")
        expect(html).to include("<li>First item</li>")
        expect(html).to include("<li>Second item</li>")
        expect(html).to include("<li>Third item</li>")
        expect(html).to include("</ul>")
      end

      it "closes list when encountering non-list content" do
        comment = create(:comment,
          content: "Some items:\n- Item one\n- Item two\n\nNot a list item\n\n- New list item",
          user: user,
          game: game)

        html = comment.content_html
        # Should have two separate lists
        expect(html.scan("<ul>").length).to eq(2)
        expect(html.scan("</ul>").length).to eq(2)
        expect(html).to include("<li>Item one</li>")
        expect(html).to include("<li>Item two</li>")
        expect(html).to include("<li>New list item</li>")
        expect(html).to include("Not a list item")
      end

      it "handles indented list items" do
        comment = create(:comment,
          content: "  - Indented item one\n  - Indented item two",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<ul>")
        expect(html).to include("<li>Indented item one</li>")
        expect(html).to include("<li>Indented item two</li>")
        expect(html).to include("</ul>")
      end

      it "works with other formatting inside list items" do
        comment = create(:comment,
          content: "Features:\n- **Bold feature**\n- *Italic feature*\n- `Code feature`",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<ul>")
        expect(html).to include("<li><strong>Bold feature</strong></li>")
        expect(html).to include("<li><em>Italic feature</em></li>")
        expect(html).to include("<li><code>Code feature</code></li>")
        expect(html).to include("</ul>")
      end

      it "works with hashtags and user mentions in list items" do
        mentioned_user = create(:user, username: "testuser")

        comment = create(:comment,
          content: "Todo:\n- Check #bugfix progress\n- Ask @testuser about feature\n- Review #performance metrics",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<ul>")
        expect(html).to include('<li>Check <span class="hashtag" data-hashtag="bugfix">#bugfix</span> progress</li>')
        expect(html).to include('<li>Ask <a href="/users/testuser" class="user-mention">@testuser</a> about feature</li>')
        expect(html).to include('<li>Review <span class="hashtag" data-hashtag="performance">#performance</span> metrics</li>')
        expect(html).to include("</ul>")
      end

      it "does not convert lines that do not match list pattern" do
        comment = create(:comment,
          content: "Not a list:\n-missing space\n*missing space\nregular text",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).not_to include("<ul>")
        expect(html).not_to include("<li>")
        expect(html).to include("-missing space")
        expect(html).to include("*missing space")
      end

      it "handles empty list items gracefully" do
        comment = create(:comment,
          content: "List with empty items:\n- First item\n- \n- Third item",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<ul>")
        expect(html).to include("<li>First item</li>")
        expect(html).to include("<li></li>")
        expect(html).to include("<li>Third item</li>")
        expect(html).to include("</ul>")
      end

      it "properly manages line breaks around lists" do
        comment = create(:comment,
          content: "Before list\n\n- Item one\n- Item two\n\nAfter list",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("Before list<br>")
        expect(html).to include("<ul>")
        expect(html).to include("<li>Item one</li>")
        expect(html).to include("<li>Item two</li>")
        expect(html).to include("</ul>")
        expect(html).to include("<br>After list")
        # Should not have <br> tags inside the list
        expect(html).not_to match(/<li>.*<br>.*<\/li>/)
      end
    end

    context "without lists" do
      it "does not affect normal content formatting" do
        comment = create(:comment,
          content: "This is **bold** and *italic* with `code` but no lists",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<strong>bold</strong>")
        expect(html).to include("<em>italic</em>")
        expect(html).to include("<code>code</code>")
        expect(html).not_to include("<ul>")
        expect(html).not_to include("<li>")
      end
    end
  end
end
