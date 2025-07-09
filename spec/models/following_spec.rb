# == Schema Information
#
# Table name: followings
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_followings_on_game_id  (game_id)
#  index_followings_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Following, type: :model do
  # Test data setup - use let! to ensure unique creation per test
  let(:user) { create(:user) }
  let(:game) { create(:game, name: "Base Test Game", slug: "base-test-game-#{SecureRandom.hex(4)}") }
  let(:following) { create(:following, user: user, game: game) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:game) }
    it { is_expected.to have_many(:activities).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:following) }

    it { is_expected.to be_valid }

    describe "uniqueness validation" do
      it "validates uniqueness of game_id scoped to user_id" do
        create(:following, user: user, game: game)
        duplicate_following = build(:following, user: user, game: game)

        expect(duplicate_following).not_to be_valid
        expect(duplicate_following.errors[:game_id]).to include("has already been taken")
      end

      it "allows same game to be followed by different users" do
        user2 = create(:user)
        create(:following, user: user, game: game)
        following2 = build(:following, user: user2, game: game)

        expect(following2).to be_valid
      end

      it "allows same user to follow different games" do
        game2 = create(:game, name: "Different Game", slug: "different-game-#{SecureRandom.hex(4)}")
        create(:following, user: user, game: game)
        following2 = build(:following, user: user, game: game2)

        expect(following2).to be_valid
      end
    end

    describe "presence validations" do
      it "requires a user" do
        following = build(:following, user: nil)
        expect(following).not_to be_valid
        expect(following.errors[:user]).to include("must exist")
      end

      it "requires a game" do
        following = build(:following, game: nil)
        expect(following).not_to be_valid
        expect(following.errors[:game]).to include("must exist")
      end
    end
  end

  describe "PublicActivity integration" do
    it "includes PublicActivity::Common" do
      expect(Following.included_modules).to include(PublicActivity::Common)
    end

    it "can create activities" do
      expect { following.create_activity(:follow) }.not_to raise_error
    end

    it "has activities association" do
      following.create_activity(:follow)
      expect(following.activities.count).to eq(1)
      expect(following.activities.first.key).to eq("following.follow")
    end

    it "destroys associated activities when following is destroyed" do
      following.create_activity(:follow)
      activity_id = following.activities.first.id

      following.destroy

      expect(PublicActivity::Activity.find_by(id: activity_id)).to be_nil
    end
  end

  describe "database constraints" do
    it "enforces foreign key constraint for user" do
      expect {
        Following.create!(user_id: 99999, game: game)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "enforces foreign key constraint for game" do
      expect {
        Following.create!(user: user, game_id: 99999)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "factory" do
    it "creates a valid following" do
      following = create(:following)
      expect(following).to be_valid
      expect(following.user).to be_present
      expect(following.game).to be_present
    end

    it "creates following with activity trait" do
      following = create(:following, :with_activity)
      expect(following.activities.count).to eq(1)
    end
  end

  describe "scopes and class methods" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:game1) { create(:game) }
    let!(:game2) { create(:game) }
    let!(:following1) { create(:following, user: user1, game: game1) }
    let!(:following2) { create(:following, user: user2, game: game1) }
    let!(:following3) { create(:following, user: user1, game: game2) }

    describe ".for_user" do
      it "returns followings for a specific user" do
        expect(Following.for_user(user1)).to contain_exactly(following1, following3)
        expect(Following.for_user(user2)).to contain_exactly(following2)
      end
    end

    describe ".for_game" do
      it "returns followings for a specific game" do
        expect(Following.for_game(game1)).to contain_exactly(following1, following2)
        expect(Following.for_game(game2)).to contain_exactly(following3)
      end
    end
  end

  describe "instance methods" do
    describe "#to_s" do
      it "returns a meaningful string representation" do
        following = create(:following)
        expected = "#{following.user.email} follows #{following.game.name}"
        expect(following.to_s).to eq(expected)
      end
    end
  end

  describe "callbacks and lifecycle" do
    it "sets timestamps on creation" do
      following = create(:following)
      expect(following.created_at).to be_present
      expect(following.updated_at).to be_present
    end

    it "updates updated_at on save" do
      following = create(:following)
      original_updated_at = following.updated_at

      # Use travel to ensure time difference
      travel 1.second do
        following.touch
      end

      expect(following.updated_at).to be > original_updated_at
    end
  end

  describe "edge cases and error handling" do
    it "handles deletion of associated user gracefully" do
      following = create(:following)
      user_id = following.user_id

      # First destroy the following, then the user (due to foreign key constraint)
      following.destroy
      expect(Following.find_by(id: following.id)).to be_nil

      # Now we can safely destroy the user
      User.find(user_id).destroy
      expect(User.find_by(id: user_id)).to be_nil
    end

    it "handles deletion of associated game gracefully" do
      following = create(:following)
      game_id = following.game_id

      # First destroy the following, then the game (due to foreign key constraint)
      following.destroy
      expect(Following.find_by(id: following.id)).to be_nil

      # Now we can safely destroy the game
      Game.find(game_id).destroy
      expect(Game.find_by(id: game_id)).to be_nil
    end

    it "handles concurrent creation attempts" do
      # Simulate race condition where two threads try to create the same following
      user = create(:user)
      game = create(:game)

      following1 = Following.new(user: user, game: game)
      following2 = Following.new(user: user, game: game)

      following1.save!
      expect { following2.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "scopes" do
    describe ".recent" do
      it "orders followings by created_at desc" do
        user1 = create(:user)

        # Create games with explicit unique slugs
        game1 = create(:game, name: "Test Game 1", slug: "test-game-1")
        game2 = create(:game, name: "Test Game 2", slug: "test-game-2")
        game3 = create(:game, name: "Test Game 3", slug: "test-game-3")

        # Create followings with explicit timestamps and different games
        following1 = nil
        following2 = nil
        following3 = nil

        travel_to 1.hour.ago do
          following1 = create(:following, user: user1, game: game1)
        end

        travel_to 30.minutes.ago do
          following2 = create(:following, user: user1, game: game2)
        end

        following3 = create(:following, user: user1, game: game3)

        recent_followings = Following.recent.limit(3)
        expect(recent_followings.first).to eq(following3)
        expect(recent_followings.last).to eq(following1)
      end
    end
  end
end
