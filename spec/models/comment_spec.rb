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
    it { should validate_length_of(:content).is_at_least(3).is_at_most(1000) }

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
end
