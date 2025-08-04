# frozen_string_literal: true

require "rails_helper"

RSpec.describe SiteSettings, type: :model do
  let(:site_settings) { SiteSettings.main }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(site_settings).to be_valid
    end

    it "requires logo_alt_text to be present" do
      site_settings.logo_alt_text = ""
      expect(site_settings).not_to be_valid
      expect(site_settings.errors[:logo_alt_text]).to include("can't be blank")
    end

    it "limits logo_alt_text to 255 characters" do
      site_settings.logo_alt_text = "a" * 256
      expect(site_settings).not_to be_valid
      expect(site_settings.errors[:logo_alt_text]).to include("is too long (maximum is 255 characters)")
    end

    it 'only allows id to be "main"' do
      new_settings = SiteSettings.new(id: "other", logo_alt_text: "Test")
      expect(new_settings).not_to be_valid
      expect(new_settings.errors[:id]).to include("is not included in the list")
    end
  end

  describe "singleton pattern" do
    it "returns the same instance when calling .main multiple times" do
      first_call = SiteSettings.main
      second_call = SiteSettings.main
      expect(first_call.id).to eq(second_call.id)
      expect(first_call.id).to eq("main")
    end

    it "prevents creating multiple instances" do
      # First, ensure a record exists
      SiteSettings.main

      # Now try to create another - should raise RecordNotUnique
      expect {
        SiteSettings.create!(id: "another", logo_alt_text: "Another")
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "#logo_url" do
    context "when no custom logo is attached" do
      it "returns the default logo asset path" do
        expect(site_settings.logo_url).to include("logo/logo")
        expect(site_settings.logo_url).to include(".png")
      end
    end

    context "when custom logo is attached" do
      it "returns the custom logo URL" do
        # Mock the attachment to avoid Active Storage complexity in tests
        allow(site_settings.logo).to receive(:attached?).and_return(true)
        allow(Rails.application.routes.url_helpers).to receive(:rails_blob_path)
          .with(site_settings.logo, only_path: true)
          .and_return("/rails/active_storage/blobs/test-logo")

        expect(site_settings.logo_url).to eq("/rails/active_storage/blobs/test-logo")
      end
    end
  end

  describe "#custom_logo?" do
    it "returns false when no logo is attached" do
      expect(site_settings.custom_logo?).to be false
    end

    context "when logo is attached" do
      it "returns true" do
        # Mock the attachment to avoid Active Storage complexity in tests
        allow(site_settings.logo).to receive(:attached?).and_return(true)
        expect(site_settings.custom_logo?).to be true
      end
    end
  end

  describe "logo format validation" do
    let(:valid_image_types) do
      %w[image/jpeg image/jpg image/png image/gif image/webp image/svg+xml]
    end

    let(:invalid_image_type) { "application/pdf" }

    context "with valid image types" do
      it "accepts valid image formats" do
        valid_image_types.each do |content_type|
          site_settings.logo.attach(
            io: StringIO.new("fake_image_data"),
            filename: "test_logo.png",
            content_type: content_type
          )
          expect(site_settings).to be_valid
          site_settings.logo.purge
        end
      end
    end

    context "with invalid image type" do
      it "rejects invalid image formats" do
        site_settings.logo.attach(
          io: StringIO.new("fake_pdf_data"),
          filename: "test.pdf",
          content_type: invalid_image_type
        )
        expect(site_settings).not_to be_valid
        expect(site_settings.errors[:logo]).to include("must be a JPEG, PNG, GIF, WebP, or SVG image")
      end
    end

    context "with file size over limit" do
      it "rejects files larger than 5MB" do
        large_data = "x" * (5.megabytes + 1)
        site_settings.logo.attach(
          io: StringIO.new(large_data),
          filename: "large_logo.png",
          content_type: "image/png"
        )
        expect(site_settings).not_to be_valid
        expect(site_settings.errors[:logo]).to include("must be less than 5MB")
      end
    end
  end
end
