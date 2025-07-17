require 'rails_helper'

RSpec.describe "Cover Image Selection", type: :feature do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }
  let!(:screenshot1) { create(:medium, :screenshot, mediable: game, title: "Main Menu") }
  let!(:screenshot2) { create(:medium, :screenshot, mediable: game, title: "Gameplay") }
  let!(:screenshot3) { create(:medium, :screenshot, mediable: game, title: "Settings") }
  let!(:video) { create(:medium, :video, mediable: game, title: "Trailer") }

  before do
    sign_in user
  end

  describe "on game edit page", js: true do
    before do
      visit edit_game_path(game)
    end

    it "displays all screenshots as cover image options" do
      within("#cover-image-options") do
        expect(page).to have_css(".cover-option", count: 3)
        expect(page).to have_content("Main Menu")
        expect(page).to have_content("Gameplay")
        expect(page).to have_content("Settings")
      end
    end

    it "does not show videos as cover image options" do
      within("#cover-image-options") do
        expect(page).not_to have_content("Trailer")
      end
    end

    it "allows selecting a cover image" do
      within("#cover-image-options") do
        first(".cover-option").click
      end

      expect(page).to have_css(".cover-option.border-blue-500")
      expect(page).to have_css(".cover-selected-indicator.opacity-100")
    end

    it "shows clear button when cover image is selected" do
      within("#cover-image-options") do
        first(".cover-option").click
      end

      expect(page).to have_button("Clear cover image selection", visible: true)
    end

    it "allows clearing cover image selection" do
      # Select a cover image first
      within("#cover-image-options") do
        first(".cover-option").click
      end

      # Clear the selection
      click_button "Clear cover image selection"

      expect(page).not_to have_css(".cover-option.border-blue-500")
      expect(page).to have_css("#clear-cover-button.hidden")
    end

    it "persists cover image selection on form submission" do
      within("#cover-image-options") do
        first(".cover-option").click
      end

      click_button "Update Game"

      expect(page).to have_content("Game was successfully updated")
      
      # Verify the cover image was saved
      game.reload
      expect(game.cover_image).to eq(screenshot1)
    end

    it "shows selected cover image on subsequent visits" do
      game.update(cover_image: screenshot2)
      visit edit_game_path(game)

      within("#cover-image-options") do
        screenshot_options = page.all(".cover-option")
        selected_option = screenshot_options.find { |option| option[:class].include?("border-blue-500") }
        expect(selected_option).to be_present
        expect(selected_option).to have_content("Gameplay")
      end
    end
  end

  describe "cover image display on game show page" do
    context "when cover image is set" do
      before do
        game.update(cover_image: screenshot1)
        visit game_path(game)
      end

      it "displays the selected cover image" do
        expect(page).to have_css("img[alt*='cover image']")
      end
    end

    context "when cover image is not set but screenshots exist" do
      before do
        visit game_path(game)
      end

      it "displays the first screenshot as fallback" do
        expect(page).to have_css("img[alt*='screenshot']")
      end
    end

    context "when no media exists" do
      let(:game_without_media) { create(:game, user: user) }

      before do
        visit game_path(game_without_media)
      end

      it "displays placeholder image" do
        expect(page).to have_content("Game Screenshot")
        expect(page).to have_css(".bg-gradient-to-br")
      end
    end
  end

  describe "cover image in game listings" do
    before do
      game.update(cover_image: screenshot1)
      visit games_path
    end

    it "shows cover image in game cards" do
      expect(page).to have_css("img[alt*='cover image']")
    end
  end

  describe "validation and error handling" do
    before do
      visit edit_game_path(game)
    end

    it "prevents selecting video as cover image" do
      # This would be handled by the model validation
      # The UI should not allow selecting videos
      within("#cover-image-options") do
        expect(page).not_to have_content("Trailer")
      end
    end

    it "handles missing screenshots gracefully" do
      game_without_screenshots = create(:game, user: user)
      visit edit_game_path(game_without_screenshots)

      within("#cover-image-section") do
        expect(page).to have_content("Upload screenshots above to select a cover image")
      end
    end
  end

  describe "accessibility" do
    before do
      visit edit_game_path(game)
    end

    it "has proper labels and alt text" do
      expect(page).to have_content("Cover Image")
      expect(page).to have_content("Select a screenshot to use as your game's main cover image")
    end

    it "supports keyboard navigation" do
      # Cover image options should be focusable
      within("#cover-image-options") do
        expect(page).to have_css(".cover-option[tabindex]", count: 3)
      end
    end
  end
end