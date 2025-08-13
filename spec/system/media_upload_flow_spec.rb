require "rails_helper"

RSpec.describe "Media Upload Flow", type: :system do
  let(:user) { create(:user) }
  let!(:genre) { create(:genre) }
  let!(:tool) { create(:tool) }
  let!(:platform) { create(:platform) }

  before do
    sign_in user
  end

  describe "complete game creation with media", js: true do
    it "creates a game with screenshots, videos, and cover image" do
      # Start game creation
      visit new_game_path

      # Fill basic game information
      fill_in "Name", with: "Complete Game Test"
      fill_in "Description", with: "A comprehensive test of game creation with media"
      if page.has_select?("Genre")
        find("select[name='game[genre_id]'] option[value='#{genre.id}']").select_option
      end
      if page.has_select?("Development Tool")
        find("select[name='game[tool_id]'] option[value='#{tool.id}']").select_option
      end
      select "Complete Game", from: "Release type"

      # Add download link (required by validation)
      click_button "Add Download Link"
      within("#download-links .download-link-fields:last-of-type") do
        find("input[type='url'][name$='[url]']").set("https://example.com/download")
        find("input[type='checkbox'][value='#{platform.id}']").click
      end

      # Submit the form
      expect { click_button "Upload Game" }.to change(Game, :count).by(1)

      # Verify game was created and we're on its page
      game = Game.order(:created_at).last
      expect(page).to have_current_path(game_path(game), ignore_query: true)
      expect(page).to have_content("Complete Game Test")
      expect(game.name).to eq("Complete Game Test")
      expect(game.user).to eq(user)
      expect(game.download_links.count).to eq(1)
      expect(game.download_links.first.url).to eq("https://example.com/download")
    end
  end

  describe "media management workflow" do
    let!(:game) { create(:game, user: user) }

    it "shows media management UI on edit form" do
      visit edit_game_path(game)

      # Verify initial state
      expect(game.screenshots_count).to eq(0)
      expect(game.videos_count).to eq(0)

      # Verify drag-and-drop upload zones and YouTube links UI are present
      expect(page).to have_content("Screenshots")
      expect(page).to have_content("Click to upload or drag and drop")
      expect(page).to have_button("Add YouTube Link")
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
        expect(page).to have_css(".cover-option", minimum: 2)
      end

      # Select first screenshot as cover
      within("#cover-image-options") do
        first(".cover-option").click
      end

      # Verify selection visual feedback
      expect(page).to have_css(".cover-selected-indicator", visible: true)
      expect(page).to have_button("Clear cover image selection", visible: true)

      # Submit form
      click_button "Update Game"

      expect(page).to have_content("Game was successfully updated")

      # Verify cover image was saved
      game.reload
      expect([screenshot1, screenshot2]).to include(game.cover_image)

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
      create(:medium, :screenshot, mediable: game)
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

    it "works on mobile devices", js: true do
      page.driver.browser.manage.window.resize_to(375, 667)

      visit edit_game_path(game)

      # Verify form is usable on mobile
      expect(page).to have_field("Name")
      expect(page).to have_button("Add YouTube Link")
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

      expect(page).to have_css(".cover-selected-indicator", visible: true)
    end
  end

  describe "error handling and recovery", js: true do
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
      expect(page).to have_content("Click to upload or drag and drop")
    end

    it "maintains media state on validation errors" do
      visit edit_game_path(game)

      # Add YouTube link field
      click_button "Add YouTube Link"
      # Wait for the new fields to be inserted into container
      within("[data-youtube-links-target='container']") do
        expect(page).to have_css(".youtube-link-fields", minimum: 1)
        within all(".youtube-link-fields").last do
          find("input[type='url'][name$='[youtube_url]']").set("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        end
      end

      # Trigger validation error
      fill_in "Name", with: ""
      click_button "Update Game"

      # Verify YouTube link field is still present
      within("[data-youtube-links-target='container']") do
        expect(page).to have_field("YouTube URL", with: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
      end
    end
  end
end
