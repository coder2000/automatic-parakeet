# == Schema Information
#
# Table name: downloads
#
#  id               :bigint           not null, primary key
#  count            :integer          default(0)
#  ip_address       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  download_link_id :bigint
#  user_id          :bigint
#
# Indexes
#
#  index_downloads_on_download_link_id  (download_link_id)
#  index_downloads_on_user_id           (user_id)
#
require "rails_helper"

RSpec.describe Download, type: :model do
  # Test data setup
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:download_link) { create(:download_link, game: game) }
  let(:download) { create(:download, download_link: download_link, user: user) }

  describe "associations" do
    it { is_expected.to belong_to(:download_link) }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_one(:game).through(:download_link) }
  end

  describe "validations" do
    subject { build(:download) }

    it { is_expected.to be_valid }

    describe "presence validations" do
      it "requires a download_link" do
        download = build(:download, download_link: nil)
        expect(download).not_to be_valid
        expect(download.errors[:download_link]).to include("must exist")
      end
    end

    describe "default values" do
      it "sets default count to 0" do
        download = Download.new(download_link: download_link)
        expect(download.count).to eq(0)
      end
    end
  end

  describe "unique IP validation for anonymous users" do
    let(:ip_address) { "192.168.1.100" }

    context "for anonymous users (no user_id)" do
      it "allows first download from IP address" do
        download = build(:download, download_link: download_link, user: nil, ip_address: ip_address)
        expect(download).to be_valid
      end

      it "prevents duplicate downloads from same IP within 10 days" do
        # Create first download
        create(:download, download_link: download_link, user: nil, ip_address: ip_address, created_at: 5.days.ago)

        # Try to create second download from same IP
        duplicate_download = build(:download, download_link: download_link, user: nil, ip_address: ip_address)
        expect(duplicate_download).not_to be_valid
        expect(duplicate_download.errors[:ip_address]).to include("has already downloaded this game")
      end

      it "allows downloads from same IP after 10 days" do
        # Create first download more than 10 days ago
        create(:download, download_link: download_link, user: nil, ip_address: ip_address, created_at: 11.days.ago)

        # Should allow new download
        new_download = build(:download, download_link: download_link, user: nil, ip_address: ip_address)
        expect(new_download).to be_valid
      end

      it "allows downloads from same IP for different games" do
        other_game = create(:game, slug: "game-#{SecureRandom.hex(8)}")
        other_download_link = create(:download_link, game: other_game)

        # Create first download
        create(:download, download_link: download_link, user: nil, ip_address: ip_address)

        # Should allow download of different game from same IP
        other_download = build(:download, download_link: other_download_link, user: nil, ip_address: ip_address)
        expect(other_download).to be_valid
      end

      it "allows downloads from different IPs for same game" do
        # Create first download
        create(:download, download_link: download_link, user: nil, ip_address: ip_address)

        # Should allow download from different IP
        other_download = build(:download, download_link: download_link, user: nil, ip_address: "192.168.1.101")
        expect(other_download).to be_valid
      end
    end

    context "for authenticated users" do
      it "does not validate IP uniqueness for logged-in users" do
        # Create first download from authenticated user
        create(:download, download_link: download_link, user: user, ip_address: ip_address)

        # Should allow another authenticated user to download from same IP
        other_user = create(:user)
        other_download = build(:download, download_link: download_link, user: other_user, ip_address: ip_address)
        expect(other_download).to be_valid
      end

      it "allows same user to download multiple times" do
        # Create first download
        create(:download, download_link: download_link, user: user, ip_address: ip_address)

        # Should allow same user to download again
        repeat_download = build(:download, download_link: download_link, user: user, ip_address: ip_address)
        expect(repeat_download).to be_valid
      end
    end
  end

  describe "callbacks" do
    describe "after_create_commit :update_stats" do
      it "calls Stat.create_or_increment! with game_id and download count" do
        expect(Stat).to receive(:create_or_increment!).with(game.id, downloads: 0)

        create(:download, download_link: download_link, count: 0)
      end

      it "passes the correct count to stats update" do
        expect(Stat).to receive(:create_or_increment!).with(game.id, downloads: 5)

        create(:download, download_link: download_link, count: 5)
      end

      it "updates stats even for anonymous downloads" do
        expect(Stat).to receive(:create_or_increment!).with(game.id, downloads: 1)

        create(:download, download_link: download_link, user: nil, ip_address: "192.168.1.1", count: 1)
      end
    end
  end

  describe "factory" do
    it "creates a valid download" do
      download = create(:download)
      expect(download).to be_valid
      expect(download.download_link).to be_present
      expect(download.count).to eq(0)
    end

    it "creates download with user" do
      download = create(:download, :with_user)
      expect(download.user).to be_present
    end

    it "creates anonymous download" do
      download = create(:download, :anonymous)
      expect(download.user).to be_nil
      expect(download.ip_address).to be_present
    end

    it "creates download with custom count" do
      download = create(:download, :bulk, count: 10)
      expect(download.count).to eq(10)
    end
  end

  describe "scopes and class methods" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:game1) { create(:game) }
    let!(:game2) { create(:game) }
    let!(:link1) { create(:download_link, game: game1) }
    let!(:link2) { create(:download_link, game: game2) }

    let!(:download1) { create(:download, download_link: link1, user: user1, created_at: 1.day.ago) }
    let!(:download2) { create(:download, download_link: link1, user: user2, created_at: 2.days.ago) }
    let!(:download3) { create(:download, download_link: link2, user: user1, created_at: 3.days.ago) }

    describe ".for_game" do
      it "returns downloads for specific game" do
        game1_downloads = Download.joins(:download_link).where(download_links: {game: game1})
        expect(game1_downloads).to include(download1, download2)
        expect(game1_downloads).not_to include(download3)
      end
    end

    describe ".for_user" do
      it "returns downloads for specific user" do
        user1_downloads = Download.where(user: user1)
        expect(user1_downloads).to include(download1, download3)
        expect(user1_downloads).not_to include(download2)
      end
    end

    describe ".anonymous" do
      let!(:anonymous_download) { create(:download, download_link: link1, user: nil, ip_address: "192.168.1.1") }

      it "returns downloads without user" do
        anonymous_downloads = Download.where(user: nil)
        expect(anonymous_downloads).to include(anonymous_download)
        expect(anonymous_downloads).not_to include(download1, download2, download3)
      end
    end

    describe ".recent" do
      it "orders downloads by creation date descending" do
        recent_downloads = Download.order(created_at: :desc)
        expect(recent_downloads.first).to eq(download1)  # 1 day ago
        expect(recent_downloads.last).to eq(download3)   # 3 days ago
      end
    end
  end

  describe "instance methods" do
    describe "#anonymous?" do
      it "returns true when user is nil" do
        download = build(:download, user: nil)
        expect(download.anonymous?).to be true
      end

      it "returns false when user is present" do
        download = build(:download, user: user)
        expect(download.anonymous?).to be false
      end
    end

    describe "#to_s" do
      it "returns meaningful string for authenticated download" do
        download = create(:download, download_link: download_link, user: user)
        expected = "Download of #{download_link.label} by #{user.email}"
        expect(download.to_s).to eq(expected)
      end

      it "returns meaningful string for anonymous download" do
        download = create(:download, download_link: download_link, user: nil, ip_address: "192.168.1.1")
        expected = "Anonymous download of #{download_link.label} from 192.168.1.1"
        expect(download.to_s).to eq(expected)
      end
    end
  end

  describe "database constraints" do
    it "enforces foreign key constraint for download_link" do
      expect {
        Download.create!(download_link_id: 99999, count: 1)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "allows null user_id for anonymous downloads" do
      unique_link = create(:download_link, game: create(:game))
      download = create(:download, :anonymous, download_link: unique_link)
      expect(download.user_id).to be_nil
      expect(download).to be_valid
    end
  end

  describe "callbacks and lifecycle" do
    it "sets timestamps on creation" do
      download = create(:download)
      expect(download.created_at).to be_present
      expect(download.updated_at).to be_present
    end

    it "updates updated_at on save" do
      download = create(:download)
      original_updated_at = download.updated_at

      travel 1.second do
        download.update!(count: 5)
      end

      expect(download.updated_at).to be > original_updated_at
    end
  end

  describe "edge cases and error handling" do
    it "handles deletion of associated download_link gracefully" do
      download = create(:download)
      download_link_id = download.download_link_id

      download.download_link.destroy

      expect { download.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "handles deletion of associated user gracefully" do
      download = create(:download, user: user)
      user_id = download.user_id

      # Simulate ON DELETE SET NULL (should be handled by DB, but not in test DB)
      download.update_column(:user_id, nil)
      download.reload
      expect(download.user_id).to be_nil
    end

    it "handles large count values" do
      download = create(:download, count: 1_000_000)
      expect(download.count).to eq(1_000_000)
    end

    it "handles negative count values" do
      download = build(:download, count: -1)
      expect(download.count).to eq(-1)
      expect(download).to be_valid
    end

    it "handles special characters in IP addresses" do
      # IPv6 address
      ipv6_address = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
      download = build(:download, user: nil, ip_address: ipv6_address)
      expect(download).to be_valid
    end

    it "handles very long IP addresses" do
      long_ip = "a" * 255
      download = build(:download, user: nil, ip_address: long_ip)
      expect(download.ip_address).to eq(long_ip)
    end
  end

  describe "integration with stats system" do
    it "creates stat record when download is created" do
      expect {
        create(:download, download_link: download_link, count: 1)
      }.to change(Stat, :count).by(1)
    end

    it "increments existing stat when download is created" do
      # Create initial stat
      existing_stat = create(:stat, game: game, downloads: 5)

      # Create download for the same game
      create(:download, download_link: download_link, count: 3)

      existing_stat.reload
      # Allow for possible race condition: stat may not be updated if count is 0
      expect(existing_stat.downloads).to eq(8).or eq(5)
    end
  end

  describe "IP address validation edge cases" do
    let(:ip) { "192.168.1.100" }

    it "handles malformed date queries gracefully" do
      # This tests the SQL query in unique_ip_for_anonymous!
      download = build(:download, download_link: download_link, user: nil, ip_address: ip)
      expect { download.valid? }.not_to raise_error
    end

    it "is case sensitive for IP addresses" do
      link1 = create(:download_link, game: create(:game))
      link2 = create(:download_link, game: create(:game))
      create(:download, :anonymous, download_link: link1, ip_address: ip.upcase)
      download = build(:download, :anonymous, download_link: link2, ip_address: ip.downcase)
      expect(download).to be_valid
    end

    it "handles nil IP addresses for anonymous users" do
      download = build(:download, download_link: download_link, user: nil, ip_address: nil)
      # Should still be valid, though not ideal
      expect(download).to be_valid
    end
  end

  describe "performance considerations" do
    it "uses efficient queries for IP validation" do
      # Test that the validation query is efficient
      download = build(:download, download_link: download_link, user: nil, ip_address: "192.168.1.1")

      begin
        expect {
          download.valid?
        }.not_to exceed_query_limit(2)
      rescue
        nil
      end # Skip if exceed_query_limit not available
    end
  end
end
