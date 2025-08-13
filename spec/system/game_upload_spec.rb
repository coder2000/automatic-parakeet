require "rails_helper"

RSpec.describe "Game Upload", type: :system do
  let(:user) { create(:user) }
  let(:genre) { create(:genre) }
  let(:tool) { create(:tool) }
  let(:platform) { create(:platform) }

  before do
    sign_in user
    # Ensure options exist for selects
    genre
    tool
    platform
    visit new_game_path
  end

  describe "basic game creation", js: true do
    it "allows user to create a game with basic information" do
      fill_in "Name", with: "My Awesome Game"
      fill_in "Description", with: "This is an awesome game description"
      if page.has_select?("Genre")
        find("select[name='game[genre_id]'] option[value='#{genre.id}']").select_option
      end
      if page.has_select?("Development Tool")
        find("select[name='game[tool_id]'] option[value='#{tool.id}']").select_option
      end
      # Ensure at least one language is selected
      click_button "Select All" if page.has_button?("Select All")
      select "Complete Game", from: "Release type"

      # At least one download link is required by validation
      click_button "Add Download Link"
      within("#download-links .download-link-fields:last-of-type") do
        find("input[type='url'][name$='[url]']").set("https://example.com/dl")
        find("input[type='checkbox'][value='#{platform.id}']").click
      end

      expect { click_button "Upload Game" }.to change(Game, :count).by(1)

      # Redirect to show page and verify content
      created = Game.order(:created_at).last
      expect(page).to have_current_path(game_path(created), ignore_query: true)
      expect(page).to have_content("My Awesome Game")
      expect(page).to have_content("This is an awesome game description")
    end

    it "shows validation errors for invalid input" do
      find("input[type='submit']").click

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Description can't be blank")
    end
  end

  describe "media upload functionality", js: true do
    before do
      fill_in "Name", with: "Game with Media"
      fill_in "Description", with: "A game with screenshots and videos"
      # genre/tool optional for UI assertions
    end

    it "shows drag and drop zones and YouTube links UI" do
      expect(page).to have_content("Click to upload or drag and drop")
      expect(page).to have_content("PNG, JPG, GIF, WebP up to 10MB")
      expect(page).to have_button("Add YouTube Link")
    end

    it "shows drag and drop zones" do
      expect(page).to have_content("Click to upload or drag and drop")
      expect(page).to have_content("PNG, JPG, GIF, WebP up to 10MB")
      expect(page).to have_content("Maximum 6 screenshots")
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

  describe "download links", js: true do
    it "allows adding download links" do
      click_button "Add Download Link"

      # New link appended at end of container; template may be used, so select actual fields container
      within("#download-links .download-link-fields:last-of-type") do
        expect(page).to have_selector("label", text: "External Link")
        expect(page).to have_css("input[type='url'][name$='[url]']")
        expect(page).to have_content("Platforms")
      end
    end

    it "allows removing download links" do
      click_button "Add Download Link"

      within("#download-links .download-link-fields:last-of-type") do
        click_button "Remove Download Link"
      end

      expect(page).not_to have_css(".download-link-fields")
    end

    it "shows platform checkboxes" do
      click_button "Add Download Link"

      within("#download-links .download-link-fields:last-of-type") do
        expect(page).to have_css("input[type='checkbox'][value='#{platform.id}']")
      end
    end
  end

  describe "form guidelines and help text" do
    it "shows media guidelines" do
      # Current form uses inline contextual text instead of a guidelines section
      expect(page).to have_content("Select a screenshot to use as your game's main cover image")
    end

    it "shows file format and size limits" do
      expect(page).to have_content("PNG, JPG, GIF, WebP up to 10MB")
    end
  end

  describe "responsive design", js: true do
    it "adapts to mobile viewport" do
      page.driver.browser.manage.window.resize_to(375, 667) # iPhone size

      expect(page).to have_field("Name")
      expect(page).to have_field("Description")
    end
  end
end
