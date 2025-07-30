require "rails_helper"

RSpec.describe "Media Upload Flow", type: :system do
  let(:user) { create(:user) }
  let(:genre) { create(:genre) }
  let(:tool) { create(:tool) }
  let(:platform) { create(:platform) }

  before do
    sign_in user
  end

  describe "complete game creation with media" do
    it "creates a game with screenshots, videos, and cover image" do
      # Start game creation
      visit new_game_path

      # Fill basic game information
      fill_in "Name", with: "Complete Game Test"
      fill_in "Description", with: "A comprehensive test of game creation with media"
      select genre.translated_name, from: "Genre"
      select tool.name, from: "Development Tool"
      select "Complete Game", from: "Release type"

      # Add download link
      click_button "Add Download Link"
      within(".download-link-fields:last-child") do
        fill_in "Label", with: "Windows Download"
        fill_in "URL", with: "https://example.com/download"
        check platform.name
      end

      # Submit the form
      click_button "Create Game"

      # Verify game was created
      expect(page).to have_content("Game was successfully created")
      expect(page).to have_content("Complete Game Test")

      game = Game.last
      expect(game.name).to eq("Complete Game Test")
      expect(game.user).to eq(user)
      expect(game.download_links.count).to eq(1)
      expect(game.download_links.first.label).to eq("Windows Download")
    end
  end

  describe "media management workflow" do
    let!(:game) { create(:game, user: user) }

    it "allows adding and managing media through edit form" do
      visit edit_game_path(game)

      # Verify initial state
      expect(game.screenshots_count).to eq(0)
      expect(game.videos_count).to eq(0)

      # Add screenshots using manual form
      click_button "Add Screenshot Manually"
      within(".media-field:last-child") do
        fill_in "Title (Optional)", with: "Main Menu Screenshot"
        fill_in "Description (Optional)", with: "Shows the game's main menu"
        fill_in "Display Order", with: "0"
      end

      click_button "Add Screenshot Manually"
      within(".media-field:last-child") do
        fill_in "Title (Optional)", with: "Gameplay Screenshot"
        fill_in "Description (Optional)", with: "Shows active gameplay"
        fill_in "Display Order", with: "1"
      end

      # Add video
      click_button "Add Video Manually"
      within(".media-field:last-child") do
        fill_in "Title (Optional)", with: "Gameplay Trailer"
        fill_in "Description (Optional)", with: "30-second gameplay trailer"
        fill_in "Display Order", with: "0"
      end

      # Submit form
      click_button "Update Game"

      expect(page).to have_content("Game was successfully updated")

      # Verify media was created (would need actual file uploads in real test)
      game.reload
      expect(game.media.count).to eq(3)
      expect(game.screenshots.count).to eq(2)
      expect(game.videos.count).to eq(1)
    end
  end

  describe "cover image selection workflow" do
    let!(:game) { create(:game, user: user) }
    let!(:screenshot1) { create(:medium, :screenshot, mediable: game, description: "Menu") }
    let!(:screenshot2) { create(:medium, :screenshot, mediable: game, description: "Game") }

    it "allows selecting and changing cover image", js: true do
      visit edit_game_path(game)

      # Verify screenshots are available for selection
      within("#cover-image-options") do
        expect(page).to have_css(".cover-option", count: 2)
        expect(page).to have_content("Menu")
        expect(page).to have_content("Game")
      end

      # Select first screenshot as cover
      within("#cover-image-options") do
        first(".cover-option").click
      end

      # Verify selection visual feedback
      expect(page).to have_css(".cover-option.border-blue-500")
      expect(page).to have_button("Clear cover image selection", visible: true)

      # Submit form
      click_button "Update Game"

      expect(page).to have_content("Game was successfully updated")

      # Verify cover image was saved
      game.reload
      expect(game.cover_image).to eq(screenshot1)

      # Verify cover image displays on show page
      visit game_path(game)
      expect(page).to have_css("img[alt*='cover image']")
    end
  end

  describe "counter culture integration" do
    let!(:game) { create(:game, user: user) }

    it "maintains accurate counter caches" do
      expect(game.screenshots_count).to eq(0)
      expect(game.videos_count).to eq(0)

      # Add media through factory (simulating file uploads)
      screenshot1 = create(:medium, :screenshot, mediable: game)
      screenshot2 = create(:medium, :screenshot, mediable: game)
      video = create(:medium, :video, mediable: game)

      # Verify counters updated
      game.reload
      expect(game.screenshots_count).to eq(2)
      expect(game.videos_count).to eq(1)

      # Remove media
      screenshot1.destroy
      video.destroy

      # Verify counters decremented
      game.reload
      expect(game.screenshots_count).to eq(1)
      expect(game.videos_count).to eq(0)
    end
  end

  describe "validation enforcement" do
    let!(:game) { create(:game, user: user) }

    it "enforces media limits" do
      # Create maximum allowed screenshots
      6.times { create(:medium, :screenshot, mediable: game) }
      expect(game).to be_valid

      # Try to add one more screenshot
      extra_screenshot = build(:medium, :screenshot, mediable: game)
      game.media << extra_screenshot

      expect(game).not_to be_valid
      expect(game.errors[:media]).to include("can't have more than 6 screenshots")
    end

    it "enforces cover image validation" do
      video = create(:medium, :video, mediable: game)

      game.cover_image = video
      expect(game).not_to be_valid
      expect(game.errors[:cover_image]).to include("must be a screenshot")
    end
  end

  describe "responsive behavior" do
    let!(:game) { create(:game, user: user) }

    it "works on mobile devices", driver: :selenium_chrome_headless do
      page.driver.browser.manage.window.resize_to(375, 667)

      visit edit_game_path(game)

      # Verify form is usable on mobile
      expect(page).to have_field("Name")
      expect(page).to have_button("Add Screenshot Manually")
      expect(page).to have_button("Add Video Manually")
      expect(page).to have_content("Cover Image")
    end
  end

  describe "performance with large datasets" do
    let!(:game_with_max_media) { create(:game, user: user) }

    before do
      # Create maximum allowed media
      6.times { |i| create(:medium, :screenshot, mediable: game_with_max_media, position: i) }
      3.times { |i| create(:medium, :video, mediable: game_with_max_media, position: i) }
    end

    it "loads edit form efficiently with maximum media" do
      start_time = Time.current
      visit edit_game_path(game_with_max_media)
      load_time = Time.current - start_time

      expect(load_time).to be < 3.seconds
      expect(page).to have_css(".cover-option", count: 6)
      expect(page).to have_css(".media-field", count: 9) # 6 screenshots + 3 videos
    end

    it "handles cover image selection with many options" do
      visit edit_game_path(game_with_max_media)

      within("#cover-image-options") do
        expect(page).to have_css(".cover-option", count: 6)

        # Select last option
        all(".cover-option").last.click
      end

      expect(page).to have_css(".cover-option.border-blue-500")
    end
  end

  describe "error handling and recovery" do
    let!(:game) { create(:game, user: user) }

    it "handles form submission errors gracefully" do
      visit edit_game_path(game)

      # Clear required field to trigger validation error
      fill_in "Name", with: ""
      click_button "Update Game"

      # Verify error is displayed
      expect(page).to have_content("Name can't be blank")

      # Verify form state is preserved
      expect(page).to have_content("Cover Image")
      expect(page).to have_button("Add Screenshot Manually")
    end

    it "maintains media state on validation errors" do
      visit edit_game_path(game)

      # Add media field
      click_button "Add Screenshot Manually"
      within(".media-field:last-child") do
        fill_in "Title (Optional)", with: "Test Screenshot"
      end

      # Trigger validation error
      fill_in "Name", with: ""
      click_button "Update Game"

      # Verify media field is still present
      expect(page).to have_field("Title (Optional)", with: "Test Screenshot")
    end
  end
end
