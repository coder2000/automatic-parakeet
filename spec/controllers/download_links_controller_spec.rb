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
          "http://user:pass@example.com/file.zip",
          "http://example.com/%0D%0ASet-Cookie:malicious=1",
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

    context "with allowlist enforced" do
      around do |example|
        original = ENV["ALLOWED_DOWNLOAD_HOSTS"]
        ENV["ALLOWED_DOWNLOAD_HOSTS"] = "example.com, github.com"
        example.run
      ensure
        ENV["ALLOWED_DOWNLOAD_HOSTS"] = original
      end

      before do
        allow(Resolv).to receive(:getaddress) do |host|
          case host
          when "example.com", "sub.example.com", "github.com", "sub.github.com"
            "93.184.216.34" # public, non-private IP
          when "notallowed.com"
            "93.184.216.34"
          else
            # fallback to original for other hosts
            Resolv::DNS.open { |dns|
              begin
                dns.getaddress(host)
              rescue
                "93.184.216.34"
              end
            }
          end
        end
      end

      it "allows hosts on the list" do
        expect(controller.send(:safe_redirect_url?, "https://example.com/file.zip")).to be true
        expect(controller.send(:safe_redirect_url?, "https://sub.example.com/file.zip")).to be true
      end

      it "blocks hosts not on the list" do
        expect(controller.send(:safe_redirect_url?, "https://notallowed.com/file.zip")).to be false
      end
    end
  end
end
