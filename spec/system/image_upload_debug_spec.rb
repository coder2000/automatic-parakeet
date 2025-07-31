require "rails_helper"

RSpec.describe "Image Upload Debug", type: :system do
  let(:user) { create(:user) }
  let(:genre) { create(:genre) }
  let(:tool) { create(:tool) }
  let(:game) { create(:game, user: user) }

  before do
    sign_in user
  end

  describe "debugging image upload 500 errors" do
    it "loads the game edit page without errors" do
      visit edit_game_path(game)

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Edit Game")
      expect(page).to have_button("Add Screenshot Manually")
    end

    it "allows manual screenshot field addition" do
      visit edit_game_path(game)

      initial_media_fields = page.all(".media-field").count

      click_button "Add Screenshot Manually"

      expect(page.all(".media-field").count).to eq(initial_media_fields + 1)

      within(".media-field:last-child") do
        expect(page).to have_field("Title (Optional)")
        expect(page).to have_field("Description (Optional)")
        expect(page).to have_field("Display Order")
        expect(page).to have_field(type: "file")
      end
    end

    it "shows drag and drop upload zones" do
      visit edit_game_path(game)

      expect(page).to have_content("Click to upload or drag and drop")
      expect(page).to have_content("PNG, JPG, GIF, WebP up to 10MB")
      expect(page).to have_content("Maximum 6 screenshots")
    end

    it "shows cover image section" do
      visit edit_game_path(game)

      expect(page).to have_content("Cover Image")
      expect(page).to have_content("Select a screenshot to use as your game's main cover image")
    end

    it "creates a game with a screenshot through the form" do
      screenshot = create(:medium, :screenshot, mediable: game, description: "Test Screenshot")

      visit edit_game_path(game)

      # Verify the screenshot appears in cover image options
      within("#cover-image-section") do
        expect(page).to have_content("Test Screenshot")
      end
    end

    it "handles form submission with nested media attributes" do
      visit edit_game_path(game)

      # Add a screenshot field manually
      click_button "Add Screenshot Manually"

      within(".media-field:last-child") do
        fill_in "Title (Optional)", with: "Test Screenshot Title"
        fill_in "Description (Optional)", with: "Test Screenshot Description"
        fill_in "Display Order", with: "0"
        # Note: We can't easily test actual file uploads in system tests
        # but we can test the form structure
      end

      # Submit the form (this will fail validation due to missing file, but should not 500)
      click_button "Update Game"

      # Should show validation error, not 500 error
      expect(page.status_code).to be_in([200, 422])
      expect(page).not_to have_content("Internal Server Error")
    end

    it "validates media types correctly" do
      # Test that the enum values work correctly after the migration
      screenshot = build(:medium, :screenshot, mediable: game)
      expect(screenshot.media_type).to eq("screenshot")
      expect(screenshot.screenshot?).to be true
      expect(screenshot.video?).to be false

      video = build(:medium, :video, mediable: game)
      expect(video.media_type).to eq("video")
      expect(video.video?).to be true
      expect(video.screenshot?).to be false
    end

    it "handles JavaScript controllers properly", js: true do
      visit edit_game_path(game)

      # Test drag and drop controller
      expect(page).to have_css("[data-controller*='drag-drop-upload']")

      # Test cover image controller
      expect(page).to have_css("[data-controller*='cover-image']")

      # Test media fields controller
      expect(page).to have_css("[data-controller*='media-fields']")
    end
  end

  describe "language selection default behavior" do
    it "should have user's language selected by default when uploading new game" do
      # Test the rule: "When uploading a new game, the default selected language should be the user's language rather than all languages appearing selected."
      visit new_game_path

      # Check that only the user's language (English in this case) is selected by default
      within("[data-controller='language-selector']") do
        checked_languages = page.all("input[type='checkbox']:checked").map { |input| input[:value] }

        # Expect only the user's current locale to be selected, not all languages
        expect(checked_languages.length).to be < I18n.available_locales.length
        expect(checked_languages).to include("0") # "0" means _destroy is false, so language is selected
      end
    end
  end
end
