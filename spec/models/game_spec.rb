# == Schema Information
#
# Table name: games
#
#  id                :bigint           not null, primary key
#  adult_content     :boolean          default(FALSE)
#  author            :string
#  description       :text             not null
#  indiepad          :boolean          default(FALSE)
#  long_description  :text
#  mobile            :boolean          default(FALSE), not null
#  name              :string           not null
#  rating_abs        :float            default(0.0), not null
#  rating_avg        :float            default(0.0), not null
#  rating_count      :integer          default(0), not null
#  release_type      :integer          default("complete"), not null
#  screenshots_count :integer          default(0), not null
#  slug              :string           not null
#  videos_count      :integer          default(0), not null
#  website           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cover_image_id    :bigint
#  genre_id          :bigint
#  tool_id           :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_games_on_author             (author)
#  index_games_on_cover_image_id     (cover_image_id)
#  index_games_on_genre_id           (genre_id)
#  index_games_on_name_and_author    (name,author) UNIQUE
#  index_games_on_screenshots_count  (screenshots_count)
#  index_games_on_tool_id            (tool_id)
#  index_games_on_user_id            (user_id)
#  index_games_on_videos_count       (videos_count)
#
# Foreign Keys
#
#  fk_rails_...  (cover_image_id => media.id)
#

require "rails_helper"

RSpec.describe Game, type: :model do
  subject(:game) { build(:game) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }

    describe "media limits validation" do
      let(:game) { create(:game) }

      context "screenshots limit" do
        it "allows up to 6 screenshots" do
          6.times { create(:medium, :screenshot, mediable: game) }
          expect(game).to be_valid
        end

        it "rejects more than 6 screenshots" do
          7.times { game.media.build(media_type: :screenshot) }
          expect(game).not_to be_valid
          expect(game.errors[:media]).to include("can't have more than 6 screenshots")
        end
      end

      context "videos limit" do
        it "allows up to 3 videos" do
          3.times { create(:medium, :video, mediable: game) }
          expect(game).to be_valid
        end

        it "rejects more than 3 videos" do
          4.times { game.media.build(media_type: :video) }
          expect(game).not_to be_valid
          expect(game.errors[:media]).to include("can't have more than 3 videos")
        end
      end
    end

    describe "cover image validation" do
      let(:game) { create(:game) }
      let(:screenshot) { create(:medium, :screenshot, mediable: game) }
      let(:video) { create(:medium, :video, mediable: game) }
      let(:other_game) { create(:game) }
      let(:other_screenshot) { create(:medium, :screenshot, mediable: other_game) }

      it "allows a screenshot as cover image" do
        game.cover_image = screenshot
        expect(game).to be_valid
      end

      it "rejects a video as cover image" do
        game.cover_image = video
        expect(game).not_to be_valid
        expect(game.errors[:cover_image]).to include("must be a screenshot")
      end

      it "rejects a screenshot from another game" do
        game.cover_image = other_screenshot
        expect(game).not_to be_valid
        expect(game.errors[:cover_image]).to include("must belong to this game")
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:genre) }
    it { is_expected.to belong_to(:tool) }
    it { is_expected.to belong_to(:cover_image).class_name("Medium").optional }
    it { is_expected.to have_many(:download_links).dependent(:destroy) }
    it { is_expected.to have_many(:activities).dependent(:destroy) }
    it { is_expected.to have_many(:ratings).dependent(:destroy) }
    it { is_expected.to have_many(:followings).dependent(:destroy) }
    it { is_expected.to have_many(:followers).through(:followings) }
    it { is_expected.to have_many(:media).dependent(:destroy) }
    it { is_expected.to have_many(:screenshots) }
    it { is_expected.to have_many(:videos) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:release_type).with_values(complete: 0, demo: 1, minigame: 2) }
  end

  describe "nested attributes" do
    it { is_expected.to accept_nested_attributes_for(:download_links).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:media).allow_destroy(true) }
  end

  describe "friendly_id" do
    it "uses friendly_id for slug" do
      game = build(:game, name: "My Awesome Game", slug: nil)
      game.save!
      expect(game.slug).to eq("my-awesome-game")
    end

    it "generates unique slugs when names conflict" do
      game1 = create(:game, name: "Duplicate Game", slug: nil)
      game2 = build(:game, name: "Duplicate Game", slug: nil)
      game2.save!

      expect(game1.slug).to eq("duplicate-game")
      expect(game2.slug).to start_with("duplicate-game-")
      expect(game2.slug).not_to eq(game1.slug)
    end

    it "can be found by slug" do
      game = create(:game, name: "Test Game")
      game.reload # Ensure slug is generated
      expect(Game.friendly.find(game.slug)).to eq(game)
    end
  end

  describe "counter culture" do
    let(:user) { create(:user) }
    let(:game) { create(:game, user: user) }

    describe "media counter caches" do
      it "initializes with zero counts" do
        expect(game.screenshots_count).to eq(0)
        expect(game.videos_count).to eq(0)
      end

      it "updates screenshots_count when screenshot is added" do
        expect { create(:medium, :screenshot, mediable: game) }
          .to change { game.reload.screenshots_count }.by(1)
      end

      it "updates videos_count when video is added" do
        expect { create(:medium, :video, mediable: game) }
          .to change { game.reload.videos_count }.by(1)
      end
    end
  end

  describe "media associations" do
    let(:game) { create(:game) }
    let!(:screenshot1) { create(:medium, :screenshot, mediable: game, position: 1) }
    let!(:screenshot2) { create(:medium, :screenshot, mediable: game, position: 0) }
    let!(:video) { create(:medium, :video, mediable: game, position: 0) }

    describe "#screenshots" do
      it "returns screenshots in order" do
        expect(game.screenshots).to eq([screenshot2, screenshot1])
      end

      it "does not include videos" do
        expect(game.screenshots).not_to include(video)
      end
    end

    describe "#videos" do
      it "returns videos in order" do
        expect(game.videos).to eq([video])
      end

      it "does not include screenshots" do
        expect(game.videos).not_to include(screenshot1, screenshot2)
      end
    end
  end

  it "defaults release_type to complete" do
    expect(game.release_type).to eq("complete")
  end
end
