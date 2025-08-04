require "rails_helper"

RSpec.describe DownloadLinksController, type: :controller do
  describe "#safe_redirect_url?" do
    subject { controller.send(:safe_redirect_url?, url) }

    context "with safe URLs" do
      let(:safe_urls) do
        [
          "https://github.com/user/repo/releases/download/v1.0/game.zip",
          "http://example.com/downloads/file.exe",
          "https://sourceforge.net/projects/game/files/game.zip"
        ]
      end

      it "returns true for safe URLs" do
        safe_urls.each do |safe_url|
          expect(controller.send(:safe_redirect_url?, safe_url)).to be true
        end
      end
    end

    context "with unsafe URLs" do
      let(:unsafe_urls) do
        [
          "http://localhost:3000/admin",
          "https://127.0.0.1:8080/secret",
          "http://192.168.1.1/config",
          "ftp://example.com/file.zip",
          "javascript:alert('xss')",
          "data:text/html,<script>alert('xss')</script>",
          "http://",
          "",
          nil
        ]
      end

      it "returns false for unsafe URLs" do
        unsafe_urls.each do |unsafe_url|
          expect(controller.send(:safe_redirect_url?, unsafe_url)).to be false
        end
      end
    end
  end
end
