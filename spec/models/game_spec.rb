# == Schema Information
#
# Table name: games
#
#  id                :bigint           not null, primary key
#  adult_content     :boolean          default(FALSE)
#  description       :text             not null
#  name              :string           not null
#  rating_abs        :float            default(0.0), not null
#  rating_avg        :float            default(0.0), not null
#  rating_count      :integer          default(0), not null
#  release_type      :integer          default("complete"), not null
#  screenshots_count :integer          default(0), not null
#  slug              :string           not null
#  videos_count      :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  genre_id          :bigint
#  tool_id           :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_games_on_genre_id           (genre_id)
#  index_games_on_screenshots_count  (screenshots_count)
#  index_games_on_tool_id            (tool_id)
#  index_games_on_user_id            (user_id)
#  index_games_on_videos_count       (videos_count)
#

require "rails_helper"

RSpec.describe Game, type: :model do
  subject(:game) { build(:game) }

  # Shoulda Matchers
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:genre) }
  it { is_expected.to belong_to(:tool) }
  it { is_expected.to have_many(:download_links).dependent(:destroy) }

  it { is_expected.to have_many(:activities).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }

  # Custom logic specs (non-shoulda)
  it "uses friendly_id for slug" do
    # Create a game with a specific name to test slug generation
    game = build(:game, name: "My Awesome Game", slug: nil)
    game.save!
    expect(game.slug).to eq("my-awesome-game")
  end

  it "generates unique slugs when names conflict" do
    # Test that FriendlyId handles duplicate names by adding unique suffixes
    game1 = create(:game, name: "Duplicate Game", slug: nil)
    game2 = build(:game, name: "Duplicate Game", slug: nil)
    game2.save!
    
    expect(game1.slug).to eq("duplicate-game")
    expect(game2.slug).to start_with("duplicate-game-")
    expect(game2.slug).not_to eq(game1.slug)
    expect(game2.slug.length).to be > "duplicate-game".length
  end

  it "defaults release_type to complete" do
    expect(game.release_type).to eq("complete")
  end
end
