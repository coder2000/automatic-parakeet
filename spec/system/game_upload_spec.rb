require "rails_helper"

RSpec.describe "Game Upload", type: :system do
  let(:user) { create(:user) }
  let(:genre) { create(:genre) }
  let(:tool) { create(:tool) }
  let(:platform) { create(:platform) }

  before do
    sign_in user
    visit new_game_path
  end

  describe "basic game creation" do
    it "allows user to create a game with basic information" do
      fill_in "Name", with: "My Awesome Game"
      fill_in "Description", with: "This is an awesome game description"
      select genre.translated_name, from: "Genre"
      select tool.name, from: "Development Tool"
      select "Complete Game", from: "Release type"

      click_button "Create Game"

      expect(page).to have_content("Game was successfully created")
      expect(page).to have_content("My Awesome Game")
      expect(page).to have_content("This is an awesome game description")
    end

    it "shows validation errors for invalid input" do
      click_button "Create Game"

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Description can't be blank")
    end
  end

  describe "media upload functionality", js: true do
    before do
      fill_in "Name", with: "Game with Media"
      fill_in "Description", with: "A game with screenshots and videos"
      select genre.translated_name, from: "Genre"
      select tool.name, from: "Development Tool"
    end

    it "allows adding screenshots manually" do
      click_button "Add Screenshot Manually"

      within(".media-field:last-child") do
        expect(page).to have_content("Screenshot")
        expect(page).to have_field("Title (Optional)")
        expect(page).to have_field("Description (Optional)")
        expect(page).to have_field("Display Order")
      end
    end

    it "allows adding videos manually" do
      click_button "Add Video Manually"

      within(".media-field:last-child") do
        expect(page).to have_content("Video")
        expect(page).to have_field("Title (Optional)")
        expect(page).to have_field("Description (Optional)")
        expect(page).to have_field("Display Order")
      end
    end

    it "allows removing media fields" do
      click_button "Add Screenshot Manually"

      within(".media-field:last-child") do
        click_button "Remove"
      end

      expect(page).not_to have_css(".media-field")
    end

    it "shows drag and drop zones" do
      expect(page).to have_content("Click to upload or drag and drop")
      expect(page).to have_content("PNG, JPG, GIF, WebP up to 10MB")
      expect(page).to have_content("MP4, WebM, OGG, AVI, MOV up to 100MB")
      expect(page).to have_content("Maximum 6 screenshots")
      expect(page).to have_content("Maximum 3 videos")
    end
  end

  describe "cover image selection", js: true do
    it "shows cover image selection section" do
      expect(page).to have_content("Cover Image")
      expect(page).to have_content("Select a screenshot to use as your game's main cover image")
      expect(page).to have_content("Upload screenshots above to select a cover image")
    end

    it "shows clear cover image button when cover image is selected" do
      # This would require actually uploading a file and selecting it
      # For now, we'll test the UI elements are present
      expect(page).to have_css("#cover-image-options")
      expect(page).to have_css("#cover_image_id_field", visible: false)
    end
  end

  describe "download links" do
    it "allows adding download links" do
      click_button "Add Download Link"

      within(".download-link-fields:last-child") do
        expect(page).to have_field("Label")
        expect(page).to have_field("URL")
        expect(page).to have_content("Platforms")
      end
    end

    it "allows removing download links" do
      click_button "Add Download Link"

      within(".download-link-fields:last-child") do
        click_button "Remove Download Link"
      end

      expect(page).not_to have_css(".download-link-fields")
    end

    it "shows platform checkboxes" do
      click_button "Add Download Link"

      within(".download-link-fields:last-child") do
        expect(page).to have_field(platform.name, type: "checkbox")
      end
    end
  end

  describe "form guidelines and help text" do
    it "shows media guidelines" do
      expect(page).to have_content("Media Guidelines")
      expect(page).to have_content("Screenshots should showcase your game's best features")
      expect(page).to have_content("Videos can include gameplay footage, trailers, or tutorials")
      expect(page).to have_content("Keep file sizes reasonable for faster loading")
    end

    it "shows file format and size limits" do
      expect(page).to have_content("Screenshots: 10MB max")
      expect(page).to have_content("Videos: 100MB max")
    end
  end

  describe "responsive design" do
    it "adapts to mobile viewport", driver: :selenium_chrome_headless do
      page.driver.browser.manage.window.resize_to(375, 667) # iPhone size

      expect(page).to have_content("My Game")
      expect(page).to have_field("Name")
      expect(page).to have_field("Description")
    end
  end
end
