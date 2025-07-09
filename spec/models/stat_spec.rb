# == Schema Information
#
# Table name: stats
#
#  id         :bigint           not null, primary key
#  downloads  :integer          default(0), not null
#  visits     :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint
#
# Indexes
#
#  index_stats_on_game_id                 (game_id)
#  index_stats_on_game_id_and_created_at  (game_id,created_at) UNIQUE
#
require "rails_helper"

RSpec.describe Stat, type: :model do
  # Test data setup
  let(:game) { create(:game) }
  let(:stat) { create(:stat, game: game) }

  describe "associations" do
    it { is_expected.to belong_to(:game) }
  end

  describe "validations" do
    subject { build(:stat) }

    it { is_expected.to be_valid }

    describe "presence validations" do
      it "requires a game" do
        stat = build(:stat, game: nil)
        expect(stat).not_to be_valid
        expect(stat.errors[:game]).to include("must exist")
      end
    end

    describe "uniqueness validation" do
      it "validates uniqueness of game_id scoped to created_at" do
        today = Time.zone.today
        create(:stat, game: game, created_at: today)
        duplicate_stat = build(:stat, game: game, created_at: today)

        expect(duplicate_stat).not_to be_valid
        expect(duplicate_stat.errors[:game_id]).to include("has already been taken")
      end

      it "allows same game to have stats on different days" do
        today = Time.zone.today
        yesterday = 1.day.ago

        create(:stat, game: game, created_at: today)
        stat_yesterday = build(:stat, game: game, created_at: yesterday)

        expect(stat_yesterday).to be_valid
      end

      it "allows different games to have stats on same day" do
        game2 = create(:game, slug: "game-#{SecureRandom.hex(8)}")
        today = Time.zone.now.beginning_of_day

        create(:stat, game: game, created_at: today)
        stat2 = build(:stat, game: game2, created_at: today)

        expect(stat2).to be_valid
      end
    end

    describe "default values" do
      it "sets default downloads to 0" do
        stat = Stat.new(game: game)
        expect(stat.downloads).to eq(0)
      end

      it "sets default visits to 0" do
        stat = Stat.new(game: game)
        expect(stat.visits).to eq(0)
      end
    end
  end

  describe "scopes" do
    let!(:game1) { create(:game, slug: "game-#{SecureRandom.hex(8)}") }
    let!(:game2) { create(:game, slug: "game-#{SecureRandom.hex(8)}") }
    let!(:today_stat) { create(:stat, game: game1, created_at: Time.zone.now.beginning_of_day) }
    let!(:yesterday_stat) { create(:stat, game: game1, created_at: 1.day.ago.beginning_of_day) }
    let!(:other_game_stat) { create(:stat, game: game2, created_at: Time.zone.now.beginning_of_day) }

    describe ".today_by_game_id" do
      it "returns stats for specific game on today" do
        result = Stat.today_by_game_id(game1.id)
        expect(result).to include(today_stat)
        expect(result).not_to include(yesterday_stat, other_game_stat)
      end

      it "returns empty when no stats for game today" do
        game3 = create(:game, slug: "game-#{SecureRandom.hex(8)}")
        result = Stat.today_by_game_id(game3.id)
        expect(result).to be_empty
      end
    end
  end

  describe "class methods" do
    describe ".create_or_increment!" do
      context "when no stat exists for today" do
        it "creates a new stat and increments counters" do
          expect {
            Stat.create_or_increment!(game.id, downloads: 1, visits: 2)
          }.to change(Stat, :count).by(1)

          stat = Stat.today_by_game_id(game.id).first
          expect(stat.downloads).to eq(1)
          expect(stat.visits).to eq(2)
        end

        it "creates stat with default values when no counters provided" do
          Stat.create_or_increment!(game.id)

          stat = Stat.today_by_game_id(game.id).first
          expect(stat.downloads).to eq(0)
          expect(stat.visits).to eq(0)
        end
      end

      context "when stat already exists for today" do
        let!(:existing_stat) do
          create(:stat,
            game: game,
            created_at: Time.zone.today,
            downloads: 5,
            visits: 10)
        end

        it "increments existing stat counters" do
          expect {
            Stat.create_or_increment!(game.id, downloads: 2, visits: 3)
          }.not_to change(Stat, :count)

          existing_stat.reload
          expect(existing_stat.downloads).to eq(7)  # 5 + 2
          expect(existing_stat.visits).to eq(13)    # 10 + 3
        end

        it "handles negative increments" do
          Stat.create_or_increment!(game.id, downloads: -1, visits: -2)

          existing_stat.reload
          expect(existing_stat.downloads).to eq(4)  # 5 - 1
          expect(existing_stat.visits).to eq(8)     # 10 - 2
        end

        it "handles partial counter updates" do
          Stat.create_or_increment!(game.id, downloads: 3)

          existing_stat.reload
          expect(existing_stat.downloads).to eq(8)  # 5 + 3
          expect(existing_stat.visits).to eq(10)    # unchanged
        end
      end
    end
  end

  describe "factory" do
    it "creates a valid stat" do
      stat = create(:stat)
      expect(stat).to be_valid
      expect(stat.game).to be_present
      expect(stat.downloads).to eq(0)
      expect(stat.visits).to eq(0)
    end

    it "creates stat with custom values" do
      stat = create(:stat, downloads: 10, visits: 20)
      expect(stat.downloads).to eq(10)
      expect(stat.visits).to eq(20)
    end
  end

  describe "database constraints" do
    it "enforces foreign key constraint for game" do
      expect {
        Stat.create!(game_id: 99999, downloads: 1, visits: 1)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "enforces unique index on game_id and created_at" do
      today = Time.zone.today
      create(:stat, game: game, created_at: today)

      expect {
        Stat.create!(game: game, created_at: today, downloads: 1, visits: 1)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "callbacks and lifecycle" do
    it "sets timestamps on creation" do
      stat = create(:stat)
      expect(stat.created_at).to be_present
      expect(stat.updated_at).to be_present
    end

    it "updates updated_at on save" do
      stat = create(:stat)
      original_updated_at = stat.updated_at

      travel 1.second do
        stat.update!(downloads: 5)
      end

      expect(stat.updated_at).to be > original_updated_at
    end
  end

  describe "edge cases and error handling" do
    it "handles deletion of associated game gracefully" do
      stat = create(:stat)
      game_id = stat.game_id

      stat.game.destroy

      expect { stat.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "handles large counter values" do
      stat = create(:stat, downloads: 1_000_000, visits: 2_000_000)
      expect(stat.downloads).to eq(1_000_000)
      expect(stat.visits).to eq(2_000_000)
    end

    it "handles zero and negative values" do
      stat = create(:stat, downloads: 0, visits: -1)
      expect(stat.downloads).to eq(0)
      expect(stat.visits).to eq(-1)
    end
  end
end
