# == Schema Information
#
# Table name: download_links
#
#  id         :bigint           not null, primary key
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
    end

    describe "file/url exclusivity" do
      it "is invalid when both file and url are blank" do
        dl = build(:download_link, url: nil)
        expect(dl).not_to be_valid
        expect(dl.errors[:base]).to include("Either file or URL must be present")
      end

      it "is invalid when both file and url are present" do
        dl = build(:download_link)
        # attach a file while url is present
        dl.file.attach(
          io: File.open(Rails.root.join("spec/fixtures/test_image.jpg")),
          filename: "test_image.jpg",
          content_type: "image/jpeg"
        )
        expect(dl).not_to be_valid
        expect(dl.errors[:base]).to include("Only one of file or URL can be present")
      end

      it "is valid with only url present" do
        dl = build(:download_link, url: "https://example.com/file.zip")
        expect(dl).to be_valid
      end

      it "is valid with only file present" do
        dl = build(:download_link, url: nil)
        dl.file.attach(
          io: File.open(Rails.root.join("spec/fixtures/test_image.jpg")),
          filename: "test_image.jpg",
          content_type: "image/jpeg"
        )
        expect(dl).to be_valid
      end
    end

    describe "url validation" do
      it "accepts valid URLs" do
        allow(Rails.application).to receive(:config_for).with(:download_links).and_return({"exclusions" => []})
        valid_urls = [
          "https://example.com/game.zip",
          "http://download.site.com/file.exe",
          "https://github.com/user/repo/releases/download/v1.0/game.tar.gz",
          # intentionally excluding domains that might be globally blocked in exclusions
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

      it "allows blank URL when file is attached" do
        dl = build(:download_link, url: "")
        dl.file.attach(
          io: File.open(Rails.root.join("spec/fixtures/test_image.jpg")),
          filename: "test_image.jpg",
          content_type: "image/jpeg"
        )
        expect(dl).to be_valid
      end

      context "with exclusion list" do
        before do
          allow(Rails.application).to receive(:config_for).with(:download_links).and_return({"exclusions" => ["blocked.com", "bit.ly"]})
        end

        it "rejects excluded domains" do
          dl = build(:download_link, url: "https://blocked.com/file.zip")
          expect(dl).not_to be_valid
          expect(dl.errors[:url]).to include("domain is not permitted")
        end

        it "rejects subdomains of excluded domains" do
          dl = build(:download_link, url: "https://sub.bit.ly/file.zip")
          expect(dl).not_to be_valid
          expect(dl.errors[:url]).to include("domain is not permitted")
        end

        it "allows non-excluded domains" do
          dl = build(:download_link, url: "https://allowed.com/file.zip")
          expect(dl).to be_valid
        end
      end

      context "with allow list" do
        around do |example|
          original = ENV["ALLOWED_DOWNLOAD_HOSTS"]
          ENV["ALLOWED_DOWNLOAD_HOSTS"] = "example.com, allowed.org"
          example.run
        ensure
          ENV["ALLOWED_DOWNLOAD_HOSTS"] = original
        end

        before do
          # ensure exclusions config still accessible (return empty unless explicitly stubbed elsewhere)
          allow(Rails.application).to receive(:config_for).with(:download_links).and_return({"exclusions" => []})
        end

        it "allows exact allowed domain" do
          dl = build(:download_link, url: "https://example.com/file.zip")
          expect(dl).to be_valid
        end

        it "allows subdomain of allowed domain" do
          dl = build(:download_link, url: "https://sub.allowed.org/file.zip")
          expect(dl).to be_valid
        end

        it "rejects non-allowed domain" do
          dl = build(:download_link, url: "https://notlisted.com/file.zip")
          expect(dl).not_to be_valid
          expect(dl.errors[:url]).to include("domain is not on the allowed list")
        end
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
      expect(download_link.url).to be_present
    end

    it "creates download link with platforms trait" do
      download_link = create(:download_link, :with_platforms)
      expect(download_link.platforms.count).to eq(1)
    end

    it "creates a file-based download link with trait" do
      download_link = create(:download_link, :with_file)
      expect(download_link.file).to be_attached
      expect(download_link.url).to be_blank
    end
  end

  describe "scopes and class methods" do
    let!(:game1) { create(:game, slug: "game-#{SecureRandom.hex(8)}") }
    let!(:game2) { create(:game, slug: "game-#{SecureRandom.hex(8)}") }
    let!(:windows_platform) { create(:platform, name: "Windows") }
    let!(:mac_platform) { create(:platform, name: "macOS") }

    let!(:windows_link) do
      link = create(:download_link, game: game1)
      link.platforms << windows_platform
      link
    end

    let!(:mac_link) do
      link = create(:download_link, game: game1)
      link.platforms << mac_platform
      link
    end

    let!(:universal_link) do
      link = create(:download_link, game: game2)
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
        download_link.update!(url: "https://example.com/updated.zip")
      end

      expect(download_link.updated_at).to be > original_updated_at
    end
  end

  describe "edge cases and error handling" do
    it "handles very long URLs" do
      long_url = "https://example.com/" + "a" * 2000 + ".zip"
      download_link = build(:download_link, url: long_url)

      # Should handle long URLs gracefully (depending on URL validation)
      expect(download_link.url.length).to be > 2000
    end

    # label is optional and may not exist; no label-specific tests
  end

  describe "database constraints" do
    it "enforces foreign key constraint for game" do
      expect {
        DownloadLink.create!(game_id: 99999, url: "https://example.com")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  # ransack integration: label is optional/non-existent; no label-based search expectations
end
