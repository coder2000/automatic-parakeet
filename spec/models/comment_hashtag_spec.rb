require "rails_helper"

RSpec.describe Comment, "hashtag functionality", type: :model do
  let(:user) { create(:user) }
  let(:game) { create(:game) }

  describe "#hashtags" do
    it "extracts hashtags from comment content" do
      comment = create(:comment,
        content: "This is an amazing #game with great #graphics and #gameplay mechanics!",
        user: user,
        game: game)

      expect(comment.hashtags).to match_array(["game", "graphics", "gameplay"])
    end

    it "handles hashtags at the beginning of content" do
      comment = create(:comment,
        content: "#awesome game with #great features",
        user: user,
        game: game)

      expect(comment.hashtags).to match_array(["awesome", "great"])
    end

    it "normalizes hashtags to lowercase" do
      comment = create(:comment,
        content: "Love this #Game and its #GRAPHICS",
        user: user,
        game: game)

      expect(comment.hashtags).to match_array(["game", "graphics"])
    end

    it "removes duplicate hashtags" do
      comment = create(:comment,
        content: "This #game is a great #game with amazing #game design",
        user: user,
        game: game)

      expect(comment.hashtags).to eq(["game"])
    end

    it "ignores hashtags that are only numbers" do
      comment = create(:comment,
        content: "Check out level #1 and #2, but #gaming is best",
        user: user,
        game: game)

      expect(comment.hashtags).to eq(["gaming"])
    end

    it "handles hashtags with underscores" do
      comment = create(:comment,
        content: "This is #game_dev at its finest #indie_games",
        user: user,
        game: game)

      expect(comment.hashtags).to match_array(["game_dev", "indie_games"])
    end

    it "returns empty array when no hashtags present" do
      comment = create(:comment,
        content: "This is a comment without any hashtags at all",
        user: user,
        game: game)

      expect(comment.hashtags).to be_empty
    end
  end

  describe "#content_html" do
    it "converts hashtags to clickable spans" do
      comment = create(:comment,
        content: "This is an amazing #game with great #graphics!",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).to include('<span class="hashtag" data-hashtag="game">#game</span>')
      expect(html).to include('<span class="hashtag" data-hashtag="graphics">#graphics</span>')
    end

    it "preserves other markdown formatting with hashtags" do
      comment = create(:comment,
        content: "This **amazing** #game has `great` *graphics*!",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).to include("<strong>amazing</strong>")
      expect(html).to include("<code>great</code>")
      expect(html).to include("<em>graphics</em>")
      expect(html).to include('<span class="hashtag" data-hashtag="game">#game</span>')
    end

    it "handles hashtags at the beginning of lines" do
      comment = create(:comment,
        content: "#awesome game\nReally love the #graphics here",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).to include('<span class="hashtag" data-hashtag="awesome">#awesome</span>')
      expect(html).to include('<span class="hashtag" data-hashtag="graphics">#graphics</span>')
    end
  end

  describe ".with_hashtag scope" do
    let!(:comment1) { create(:comment, content: "This is an amazing #game with great features!", user: user, game: game) }
    let!(:comment2) { create(:comment, content: "Love the #graphics in this #game so much", user: user, game: game) }
    let!(:comment3) { create(:comment, content: "Great soundtrack and #music in this game", user: user, game: game) }
    let!(:comment4) { create(:comment, content: "No hashtags here but this is a valid comment", user: user, game: game) }

    it "finds comments with specific hashtag" do
      results = Comment.with_hashtag("game")
      expect(results).to include(comment1, comment2)
      expect(results).not_to include(comment3, comment4)
    end

    it "is case insensitive" do
      results = Comment.with_hashtag("GAME")
      expect(results).to include(comment1, comment2)
    end

    it "handles hashtag with # prefix" do
      results = Comment.with_hashtag("#game")
      expect(results).to include(comment1, comment2)
    end

    it "finds comments with different hashtag" do
      results = Comment.with_hashtag("music")
      expect(results).to include(comment3)
      expect(results).not_to include(comment1, comment2, comment4)
    end

    it "returns empty when hashtag not found" do
      results = Comment.with_hashtag("nonexistent")
      expect(results).to be_empty
    end

    it "returns none when hashtag is blank" do
      results = Comment.with_hashtag("")
      expect(results).to be_empty
    end
  end
end
