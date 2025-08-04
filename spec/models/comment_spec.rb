require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:game) { create(:game) }

  describe "associations" do
    it { should belong_to(:game) }
    it { should belong_to(:user) }
    it { should belong_to(:parent).class_name("Comment").optional }
    it { should have_many(:replies).class_name("Comment").with_foreign_key("parent_id").dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:comment, game: game, user: user) }

    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_least(20).is_at_most(500) }

    context "when parent comment exists" do
      let(:parent_comment) { create(:comment, game: game, user: user) }
      let(:reply) { build(:comment, game: game, user: user, parent: parent_comment) }

      it "allows replies to top-level comments" do
        expect(reply).to be_valid
      end

      it "validates parent belongs to same game" do
        other_game = create(:game)
        other_parent = create(:comment, game: other_game, user: user)
        reply.parent = other_parent

        expect(reply).not_to be_valid
        expect(reply.errors[:parent]).to include("must belong to the same game")
      end

      it "prevents deeply nested replies" do
        nested_reply = build(:comment, game: game, user: user, parent: reply)
        reply.save!

        expect(nested_reply).not_to be_valid
        expect(nested_reply.errors[:parent]).to include("cannot reply to a reply (only one level of nesting allowed)")
      end
    end
  end

  describe "scopes" do
    let!(:top_level_comment) { create(:comment, game: game, user: user) }
    let!(:reply) { create(:comment, game: game, user: user, parent: top_level_comment) }
    let!(:older_comment) { create(:comment, game: game, user: user, created_at: 1.day.ago) }

    describe ".top_level" do
      it "returns only comments without parents" do
        expect(Comment.top_level).to include(top_level_comment, older_comment)
        expect(Comment.top_level).not_to include(reply)
      end
    end

    describe ".ordered" do
      it "returns comments ordered by created_at ascending" do
        expect(Comment.ordered.first).to eq(older_comment)
        expect(Comment.ordered.last).to eq(reply)
      end
    end

    describe ".recent" do
      it "returns comments ordered by created_at descending" do
        expect(Comment.recent.first).to eq(reply)
        expect(Comment.recent.last).to eq(older_comment)
      end
    end
  end

  describe "methods" do
    let(:comment) { create(:comment, game: game, user: user) }
    let(:reply) { create(:comment, game: game, user: user, parent: comment) }

    describe "#top_level?" do
      it "returns true for comments without parents" do
        expect(comment.top_level?).to be true
      end

      it "returns false for replies" do
        expect(reply.top_level?).to be false
      end
    end

    describe "#reply?" do
      it "returns false for comments without parents" do
        expect(comment.reply?).to be false
      end

      it "returns true for replies" do
        expect(reply.reply?).to be true
      end
    end

    describe "#can_be_replied_to?" do
      it "returns true for top-level comments" do
        expect(comment.can_be_replied_to?).to be true
      end

      it "returns false for replies" do
        expect(reply.can_be_replied_to?).to be false
      end
    end
  end

  describe "self-referential functionality" do
    let(:parent_comment) { create(:comment, game: game, user: user) }
    let!(:reply1) { create(:comment, game: game, user: user, parent: parent_comment) }
    let!(:reply2) { create(:comment, game: game, user: user, parent: parent_comment) }

    it "allows multiple replies to the same parent" do
      expect(parent_comment.replies).to include(reply1, reply2)
      expect(parent_comment.replies.count).to eq(2)
    end

    it "destroys replies when parent is destroyed" do
      expect {
        parent_comment.destroy
      }.to change { Comment.count }.by(-3) # parent + 2 replies
    end

    it "maintains correct parent-child relationships" do
      expect(reply1.parent).to eq(parent_comment)
      expect(reply2.parent).to eq(parent_comment)
      expect(parent_comment.parent).to be_nil
    end
  end

  describe "anti-spam validation" do
    let(:user) { create(:user) }
    let(:game) { create(:game) }

    context "when user has no previous comments" do
      it "allows the comment" do
        comment = build(:comment, game: game, user: user, content: "This is a valid comment")
        expect(comment).to be_valid
      end
    end

    context "when user posted more than 2 minutes ago" do
      before do
        create(:comment, game: game, user: user, content: "This is a valid comment with enough characters", created_at: 3.minutes.ago)
      end

      it "allows the new comment" do
        comment = build(:comment, game: game, user: user, content: "This is a new comment with sufficient length")
        expect(comment).to be_valid
      end
    end

    context "when user posted more than 5 minutes ago" do
      before do
        create(:comment, game: game, user: user, content: "This is a valid old comment with enough characters", created_at: 6.minutes.ago)
      end

      it "allows the new comment" do
        comment = build(:comment, game: game, user: user, content: "This is a new comment with sufficient length")
        expect(comment).to be_valid
      end
    end

    context "when user posted less than 2 minutes ago" do
      context "and previous comment was short (less than 20 characters)" do
        before do
          # Create a comment that bypasses validation to test spam protection
          comment = Comment.new(game: game, user: user, content: "short msg", created_at: 1.minute.ago)
          comment.save(validate: false)
        end

        it "blocks the new comment with spam protection message" do
          comment = build(:comment, game: game, user: user, content: "This is a new comment with sufficient length")
          expect(comment).not_to be_valid
          expect(comment.errors[:base]).to include(match(/Please wait.*seconds before posting again/))
        end
      end

      context "and previous comment was long (20+ characters)" do
        before do
          create(:comment, game: game, user: user, content: "This is a long comment with more than twenty characters", created_at: 1.minute.ago)
        end

        it "allows the new comment" do
          comment = build(:comment, game: game, user: user, content: "This is a new comment with sufficient length")
          expect(comment).to be_valid
        end
      end

      context "and previous comment contained the same text" do
        before do
          create(:comment, game: game, user: user, content: "This is the same comment", created_at: 1.minute.ago)
        end

        it "blocks the duplicate comment" do
          comment = build(:comment, game: game, user: user, content: "This is the same comment")
          expect(comment).not_to be_valid
          expect(comment.errors[:base]).to include(match(/Please wait.*seconds before posting again/))
        end

        it "blocks case-insensitive duplicates" do
          comment = build(:comment, game: game, user: user, content: "THIS IS THE SAME COMMENT")
          expect(comment).not_to be_valid
        end

        it "blocks duplicates ignoring whitespace" do
          comment = build(:comment, game: game, user: user, content: "  This is the same comment  ")
          expect(comment).not_to be_valid
        end
      end

      context "and previous comment contained a link" do
        before do
          create(:comment, game: game, user: user, content: "Check out https://example.com", created_at: 1.minute.ago)
        end

        it "blocks the new comment" do
          comment = build(:comment, game: game, user: user, content: "This is a new comment without links but with enough length")
          expect(comment).not_to be_valid
          expect(comment.errors[:base]).to include(match(/Please wait.*seconds before posting again/))
        end
      end
    end
  end

  describe "#contains_link?" do
    let(:comment) { Comment.new }

    it "detects http links" do
      expect(comment.send(:contains_link?, "Visit http://example.com")).to be true
    end

    it "detects https links" do
      expect(comment.send(:contains_link?, "Visit https://example.com")).to be true
    end

    it "detects www links" do
      expect(comment.send(:contains_link?, "Visit www.example.com")).to be true
    end

    it "detects links with paths" do
      expect(comment.send(:contains_link?, "Visit https://example.com/path/to/page")).to be true
    end

    it "detects links with query parameters" do
      expect(comment.send(:contains_link?, "Visit https://example.com?param=value")).to be true
    end

    it "does not detect non-links" do
      expect(comment.send(:contains_link?, "This is just plain text")).to be false
    end

    it "does not detect incomplete URLs" do
      expect(comment.send(:contains_link?, "example.com")).to be false
    end
  end
end
