require "rails_helper"

RSpec.describe Comment, "spoiler text functionality", type: :model do
  let(:user) { create(:user) }
  let(:game) { create(:game) }

  describe "#content_html" do
    context "with spoiler text" do
      it "converts single spoiler text to HTML span with spoiler class" do
        comment = create(:comment,
          content: "This game has an amazing ||plot twist at the end||!",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">plot twist at the end</span>')
        expect(html).to include("This game has an amazing")
        expect(html).to include("!")
      end

      it "converts multiple spoiler texts in the same comment" do
        comment = create(:comment,
          content: "Warning: ||major boss fight|| and ||character death|| ahead!",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">major boss fight</span>')
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">character death</span>')
        expect(html).to include("Warning:")
        expect(html).to include("and")
        expect(html).to include("ahead!")
      end

      it "works with other formatting inside spoiler text" do
        comment = create(:comment,
          content: "Spoiler: ||The **main character** actually uses `magic_spell()` to *defeat* the villain||",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">The <strong>main character</strong> actually uses <code>magic_spell()</code> to <em>defeat</em> the villain</span>')
      end

      it "works with hashtags and user mentions inside spoiler text" do
        mentioned_user = create(:user, username: "testuser")

        comment = create(:comment,
          content: "Major spoiler: ||@testuser was right about #ending being predictable||",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler"><a href="/users/testuser" class="user-mention">@testuser</a> was right about <span class="hashtag" data-hashtag="ending">#ending</span> being predictable</span>')
      end

      it "works with spoilers inside list items" do
        comment = create(:comment,
          content: "Game features:\n- Great graphics\n- ||Secret ending|| unlockable\n- Multiple difficulty levels",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<ul>")
        expect(html).to include("<li>Great graphics</li>")
        expect(html).to include('<li><span class="spoiler" title="Click to reveal spoiler">Secret ending</span> unlockable</li>')
        expect(html).to include("<li>Multiple difficulty levels</li>")
        expect(html).to include("</ul>")
      end

      it "does not convert single pipes or incomplete spoiler tags" do
        comment = create(:comment,
          content: "This has |single pipes| and ||incomplete spoiler tag and regular text",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("|single pipes|")
        expect(html).to include("||incomplete spoiler tag")
        expect(html).not_to include('<span class="spoiler"')
      end

      it "handles empty spoiler tags" do
        comment = create(:comment,
          content: "This has empty spoiler tags: |||| and some regular text",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler"></span>')
        expect(html).to include("and some regular text")
      end

      it "handles spoilers with newlines inside" do
        comment = create(:comment,
          content: "Multi-line spoiler: ||First line\nSecond line|| end of spoiler",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">First line<br>Second line</span>')
        expect(html).to include("end of spoiler")
      end

      it "handles nested formatting correctly with spoilers" do
        comment = create(:comment,
          content: "The game has **amazing** graphics and ||the **final boss** is *incredibly* difficult||!",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<strong>amazing</strong>")
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">the <strong>final boss</strong> is <em>incredibly</em> difficult</span>')
      end

      it "handles spoilers at the beginning of content" do
        comment = create(:comment,
          content: "||Spoiler at start|| and then regular text continues here",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">Spoiler at start</span>')
        expect(html).to include("and then regular text continues here")
      end

      it "handles spoilers at the end of content" do
        comment = create(:comment,
          content: "Regular text first and then ||spoiler at the end||",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("Regular text first and then")
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">spoiler at the end</span>')
      end

      it "handles multiple consecutive spoilers" do
        comment = create(:comment,
          content: "Multiple spoilers: ||first spoiler|| ||second spoiler|| ||third spoiler||",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">first spoiler</span>')
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">second spoiler</span>')
        expect(html).to include('<span class="spoiler" title="Click to reveal spoiler">third spoiler</span>')
      end

      it "preserves spacing around spoilers" do
        comment = create(:comment,
          content: "Text before ||spoiler content|| text after",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include('Text before <span class="spoiler" title="Click to reveal spoiler">spoiler content</span> text after')
      end
    end

    context "without spoilers" do
      it "does not affect normal content formatting" do
        comment = create(:comment,
          content: "This is **bold** and *italic* with `code` but no spoilers",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<strong>bold</strong>")
        expect(html).to include("<em>italic</em>")
        expect(html).to include("<code>code</code>")
        expect(html).not_to include('<span class="spoiler"')
      end

      it "handles content with pipe characters that are not spoilers" do
        comment = create(:comment,
          content: "This has | pipe characters | but they are not spoiler markers",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("| pipe characters |")
        expect(html).not_to include('<span class="spoiler"')
      end
    end

    context "integration with other features" do
      it "maintains correct processing order with all features" do
        mentioned_user = create(:user, username: "player")

        comment = create(:comment,
          content: "Review:\n- **Great** graphics\n- @player found #bug in ||secret level||\n- *Amazing* `soundtrack.mp3`",
          user: user,
          game: game)

        html = comment.content_html
        expect(html).to include("<ul>")
        expect(html).to include("<li><strong>Great</strong> graphics</li>")
        expect(html).to include('<li><a href="/users/player" class="user-mention">@player</a> found <span class="hashtag" data-hashtag="bug">#bug</span> in <span class="spoiler" title="Click to reveal spoiler">secret level</span></li>')
        expect(html).to include("<li><em>Amazing</em> <code>soundtrack.mp3</code></li>")
        expect(html).to include("</ul>")
      end

      it "works with existing validation rules" do
        comment = build(:comment,
          content: "||Short spoiler||", # Only 17 characters, should fail minimum
          user: user,
          game: game)

        expect(comment).not_to be_valid
        expect(comment.errors[:content]).to include("is too short (minimum is 20 characters)")
      end
    end
  end
end
