require "rails_helper"

RSpec.describe Comment, "user mention functionality", type: :model do
  let(:user) { create(:user) }
  let(:mentioned_user) { create(:user, username: "testuser") }
  let(:another_user) { create(:user, username: "another_user") }
  let(:game) { create(:game) }

  describe "#mentioned_users" do
    it "finds users mentioned in comment content" do
      comment = create(:comment,
        content: "Hey @testuser, check out this awesome game! @another_user might like it too.",
        user: user,
        game: game)

      expect(comment.mentioned_users).to include(mentioned_user, another_user)
    end

    it "handles mentions at the beginning of content" do
      comment = create(:comment,
        content: "@testuser this is an amazing game with great features",
        user: user,
        game: game)

      expect(comment.mentioned_users).to include(mentioned_user)
    end

    it "ignores non-existent users" do
      comment = create(:comment,
        content: "Hey @nonexistent and @testuser, check this out!",
        user: user,
        game: game)

      expect(comment.mentioned_users).to include(mentioned_user)
      expect(comment.mentioned_users).not_to include(User.find_by(username: "nonexistent"))
    end

    it "handles usernames with numbers and underscores" do
      numbered_user = create(:user, username: "user123")
      underscore_user = create(:user, username: "test_user")

      comment = create(:comment,
        content: "Thanks @user123 and @test_user for the feedback!",
        user: user,
        game: game)

      expect(comment.mentioned_users).to include(numbered_user, underscore_user)
    end

    it "returns empty collection when no users mentioned" do
      comment = create(:comment,
        content: "This is a comment without any user mentions at all",
        user: user,
        game: game)

      expect(comment.mentioned_users).to be_empty
    end

    it "handles duplicate mentions of the same user" do
      mentioned_user # Ensure user exists

      comment = create(:comment,
        content: "@testuser thanks! @testuser you should check this out again @testuser",
        user: user,
        game: game)

      expect(comment.mentioned_users.count).to eq(1)
      expect(comment.mentioned_users).to include(mentioned_user)
    end
  end

  describe "#content_html" do
    it "converts user mentions to clickable links for existing users" do
      # Ensure the mentioned user exists before creating the comment
      mentioned_user # This creates the user

      comment = create(:comment,
        content: "Hey @testuser, check out this game!",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).to include('<a href="/users/testuser" class="user-mention">@testuser</a>')
    end

    it "leaves non-existent user mentions as plain text" do
      comment = create(:comment,
        content: "Hey @nonexistent, check this out!",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).to include("@nonexistent")
      expect(html).not_to include('<a href="/users/nonexistent"')
    end

    it "preserves other markdown formatting with user mentions" do
      mentioned_user # Ensure user exists

      comment = create(:comment,
        content: "This **amazing** @testuser has `great` *games*!",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).to include("<strong>amazing</strong>")
      expect(html).to include("<code>great</code>")
      expect(html).to include("<em>games</em>")
      expect(html).to include('<a href="/users/testuser" class="user-mention">@testuser</a>')
    end

    it "handles mentions at the beginning of lines" do
      mentioned_user # Ensure users exist
      another_user

      comment = create(:comment,
        content: "@testuser awesome game\nReally love this @another_user",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).to include('<a href="/users/testuser" class="user-mention">@testuser</a>')
      expect(html).to include('<a href="/users/another_user" class="user-mention">@another_user</a>')
    end

    it "works alongside hashtags" do
      mentioned_user # Ensure user exists

      comment = create(:comment,
        content: "Hey @testuser, this #game is amazing!",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).to include('<a href="/users/testuser" class="user-mention">@testuser</a>')
      expect(html).to include('<span class="hashtag" data-hashtag="game">#game</span>')
    end

    it "handles case-sensitive usernames correctly" do
      caps_user = create(:user, username: "TestUser")

      comment = create(:comment,
        content: "Hey @TestUser, great work on the game!",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).to include('<a href="/users/TestUser" class="user-mention">@TestUser</a>')
    end

    it "does not convert mentions in the middle of words" do
      comment = create(:comment,
        content: "This email@testuser.com is not a mention",
        user: user,
        game: game)

      html = comment.content_html
      expect(html).not_to include('<a href="/users/testuser"')
      expect(html).to include("email@testuser.com")
    end
  end

  describe "integration with existing features" do
    it "works with existing validation rules" do
      comment = build(:comment,
        content: "@testuser great!", # Only 17 characters, should fail minimum
        user: user,
        game: game)

      expect(comment).not_to be_valid
      expect(comment.errors[:content]).to include("is too short (minimum is 20 characters)")
    end

    it "works with spam protection" do
      # Create a short comment first (bypassing validation)
      first_comment = Comment.new(
        content: "short",
        user: user,
        game: game,
        created_at: 1.minute.ago
      )
      first_comment.save(validate: false)

      new_comment = build(:comment,
        content: "Hey @testuser, check this amazing game out!",
        user: user,
        game: game)

      expect(new_comment).not_to be_valid
      expect(new_comment.errors[:base]).to include(match(/Please wait.*seconds before posting again/))
    end
  end
end
