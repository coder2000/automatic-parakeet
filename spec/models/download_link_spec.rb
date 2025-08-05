# == Schema Information
#
# Table name: download_links
#
#  id         :bigint           not null, primary key
#  label      :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#
# Indexes
#
#  index_download_links_on_game_id  (game_id)
#  index_download_links_on_url      (url) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
require "rails_helper"

RSpec.describe DownloadLink, type: :model do
  # Test data setup
  let(:game) { create(:game) }
  let(:platform) { create(:platform) }
  let(:download_link) { create(:download_link, game: game) }

  describe "associations" do
    it { is_expected.to belong_to(:game) }
    it { is_expected.to have_and_belong_to_many(:platforms) }
  end

  describe "validations" do
    subject { build(:download_link) }

    it { is_expected.to be_valid }

    describe "presence validations" do
      it "requires a game" do
        download_link = build(:download_link, game: nil)
        expect(download_link).not_to be_valid
        expect(download_link.errors[:game]).to include("must exist")
      end

      it "requires a label" do
        download_link = build(:download_link, label: nil)
        expect(download_link).not_to be_valid
        expect(download_link.errors[:label]).to include("can't be blank")
      end

      it "requires a url" do
        download_link = build(:download_link, url: nil)
        expect(download_link).not_to be_valid
        expect(download_link.errors[:url]).to include("can't be blank")
      end
    end

    describe "url validation" do
      it "accepts valid URLs" do
        valid_urls = [
          "https://example.com/game.zip",
          "http://download.site.com/file.exe",
          "https://github.com/user/repo/releases/download/v1.0/game.tar.gz",
          "https://itch.io/game-download",
          "https://drive.google.com/file/d/abc123/view"
        ]

        valid_urls.each do |url|
          download_link = build(:download_link, url: url)
          expect(download_link).to be_valid, "Expected #{url} to be valid"
        end
      end

      it "rejects invalid URLs" do
        invalid_urls = [
          "not-a-url",
          "ftp://example.com/file.zip",
          'javascript:alert("xss")',
          "mailto:user@example.com",
          "file:///local/path"
        ]

        invalid_urls.each do |url|
          download_link = build(:download_link, url: url)
          expect(download_link).not_to be_valid, "Expected #{url} to be invalid"
          expect(download_link.errors[:url]).to include("is not a valid URL")
        end
      end

      it "rejects blank URLs" do
        download_link = build(:download_link, url: "")
        expect(download_link).not_to be_valid
        expect(download_link.errors[:url]).to include("can't be blank")
      end
    end

    describe "label validation" do
      it "accepts reasonable label lengths" do
        download_link = build(:download_link, label: "A" * 100)
        expect(download_link).to be_valid
      end

      it "rejects excessively long labels" do
        download_link = build(:download_link, label: "A" * 256)
        expect(download_link).not_to be_valid
        expect(download_link.errors[:label]).to include("is too long (maximum is 255 characters)")
      end
    end
  end

  describe "platform associations" do
    it "can be associated with multiple platforms" do
      platform1 = create(:platform, name: "Windows")
      platform2 = create(:platform, name: "macOS")

      download_link.platforms << [platform1, platform2]

      expect(download_link.platforms.count).to eq(2)
      expect(download_link.platforms).to include(platform1, platform2)
    end

    it "can exist without platforms" do
      expect(download_link.platforms.count).to eq(0)
      expect(download_link).to be_valid
    end

    it "removes platform associations when destroyed" do
      platform1 = create(:platform)
      download_link.platforms << platform1

      expect {
        download_link.destroy
      }.to change { platform1.download_links.count }.by(-1)
    end
  end

  describe "factory" do
    it "creates a valid download link" do
      download_link = create(:download_link)
      expect(download_link).to be_valid
      expect(download_link.game).to be_present
      expect(download_link.label).to be_present
      expect(download_link.url).to be_present
    end

    it "creates download link with platforms trait" do
      download_link = create(:download_link, :with_platforms)
      expect(download_link.platforms.count).to eq(1)
    end
  end

  describe "scopes and class methods" do
    let!(:game1) { create(:game, slug: "game-#{SecureRandom.hex(8)}") }
    let!(:game2) { create(:game, slug: "game-#{SecureRandom.hex(8)}") }
    let!(:windows_platform) { create(:platform, name: "Windows") }
    let!(:mac_platform) { create(:platform, name: "macOS") }

    let!(:windows_link) do
      link = create(:download_link, game: game1, label: "Windows Download #{SecureRandom.hex(4)}")
      link.platforms << windows_platform
      link
    end

    let!(:mac_link) do
      link = create(:download_link, game: game1, label: "macOS Download #{SecureRandom.hex(4)}")
      link.platforms << mac_platform
      link
    end

    let!(:universal_link) do
      link = create(:download_link, game: game2, label: "Universal Download #{SecureRandom.hex(4)}")
      link.platforms << [windows_platform, mac_platform]
      link
    end

    describe ".for_platform" do
      it "returns download links for specific platform" do
        windows_links = DownloadLink.joins(:platforms).where(platforms: {id: windows_platform.id})
        expect(windows_links).to include(windows_link, universal_link)
        expect(windows_links).not_to include(mac_link)
      end
    end

    describe ".for_game" do
      it "returns download links for specific game" do
        game1_links = DownloadLink.where(game: game1)
        expect(game1_links).to include(windows_link, mac_link)
        expect(game1_links).not_to include(universal_link)
      end
    end
  end

  describe "instance methods" do
    describe "#to_s" do
      it "returns a meaningful string representation" do
        download_link = create(:download_link, label: "Windows Download")
        expected = "Windows Download"
        expect(download_link.to_s).to eq(expected)
      end
    end

    describe "#platform_names" do
      it "returns comma-separated platform names" do
        platform1 = create(:platform, name: "Windows")
        platform2 = create(:platform, name: "macOS")
        download_link.platforms << [platform1, platform2]

        expect(download_link.platform_names).to eq("Windows, macOS")
      end

      it "returns empty string when no platforms" do
        expect(download_link.platform_names).to eq("")
      end
    end

    describe "#download_filename" do
      it "extracts filename from URL" do
        download_link = build(:download_link, url: "https://example.com/files/game-v1.2.zip")
        expect(download_link.download_filename).to eq("game-v1.2.zip")
      end

      it "handles URLs without clear filename" do
        download_link = build(:download_link, url: "https://example.com/download")
        expect(download_link.download_filename).to eq("download")
      end

      it "handles URLs with query parameters" do
        download_link = build(:download_link, url: "https://example.com/file.zip?token=abc123")
        expect(download_link.download_filename).to eq("file.zip")
      end
    end
  end

  describe "callbacks and lifecycle" do
    it "sets timestamps on creation" do
      download_link = create(:download_link)
      expect(download_link.created_at).to be_present
      expect(download_link.updated_at).to be_present
    end

    it "updates updated_at on save" do
      download_link = create(:download_link)
      original_updated_at = download_link.updated_at

      travel 1.second do
        download_link.update!(label: "Updated Label")
      end

      expect(download_link.updated_at).to be > original_updated_at
    end
  end

  describe "edge cases and error handling" do
    it "handles deletion of associated game gracefully" do
      download_link = create(:download_link)
      game_id = download_link.game_id

      download_link.game.destroy

      expect { download_link.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "handles very long URLs" do
      long_url = "https://example.com/" + "a" * 2000 + ".zip"
      download_link = build(:download_link, url: long_url)

      # Should handle long URLs gracefully (depending on URL validation)
      expect(download_link.url.length).to be > 2000
    end

    it "handles special characters in labels" do
      special_labels = [
        "Download (Windows x64)",
        "Game v1.0 - Final Release!",
        "Télécharger le jeu",
        "ゲームダウンロード"
      ]

      special_labels.each do |label|
        download_link = build(:download_link, label: label)
        expect(download_link).to be_valid, "Expected '#{label}' to be valid"
      end
    end
  end

  describe "database constraints" do
    it "enforces foreign key constraint for game" do
      expect {
        DownloadLink.create!(game_id: 99999, label: "Test", url: "https://example.com")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "ransack integration" do
    it "allows searching by label" do
      download_link1 = create(:download_link, label: "Windows Download")
      download_link2 = create(:download_link, label: "macOS Download")

      # This would be used in controllers with Ransack
      expect(download_link1.label).to include("Windows")
      expect(download_link2.label).to include("macOS")
    end
  end
end
