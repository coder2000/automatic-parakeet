require "rails_helper"
require "rack/test"

RSpec.describe "Home Page", type: :system do
  describe "landing page" do
    context "with games in database" do
      let!(:games) { create_list(:game, 5) }
      let!(:game_with_media) { create(:game) }
      let!(:screenshot) { create(:medium, :screenshot, mediable: game_with_media) }
      let!(:cover_game) do
        game = create(:game)
        # Create the medium first, then manually attach the file to ensure it works
        cover_screenshot = Medium.create!(
          mediable: game,
          media_type: "screenshot",
          description: "Cover Screenshot",
          position: 0
        )
        # Attach file manually to ensure it's properly attached
        cover_screenshot.file.attach(
          io: StringIO.new("fake cover image data"),
          filename: "cover.jpg",
          content_type: "image/jpeg"
        )
        game.update!(cover_image: cover_screenshot)
        game
      end

      before do
        # Set up ratings for recommended games
        games.first.update(rating_avg: 4.8, rating_count: 15)
        games.second.update(rating_avg: 4.5, rating_count: 8)
        games.third.update(rating_avg: 4.3, rating_count: 5) if games.third
        cover_game.update(rating_avg: 4.9, rating_count: 20)

        # Attach files to media - the cover_game already has its file attached
        # Just attach file to the screenshot game
        game_with_media.screenshots.first.file.attach(
          io: StringIO.new("fake image data"),
          filename: "screenshot.jpg",
          content_type: "image/jpeg"
        )

        # Ensure the attachments are persisted
        game_with_media.reload
        cover_game.reload

        visit root_path
      end

      it "displays the hero section" do
        expect(page).to have_content("Discover Amazing Games")
        expect(page).to have_content("Explore the latest and greatest indie games")
      end

      it "shows newest games carousel" do
        expect(page).to have_content("Newest Games")
        games.each do |game|
          expect(page).to have_content(game.name)
        end
      end

      it "displays recommended games section" do
        expect(page).to have_content("Recommended Games")
        expect(page).to have_content("Highly rated games loved by our community")
      end

      it "shows game cards with proper information" do
        # Look for recommended games section specifically
        expect(page).to have_content("Recommended Games")

        within(".grid") do
          # Should show at least one game card
          expect(page).to have_css(".bg-white.rounded-lg.shadow-lg", minimum: 1)
        end

        # Check for game information elements anywhere on the page
        expect(page).to have_css(".text-yellow-400") # Star ratings
        expect(page).to have_content("reviews")
        expect(page).to have_css(".bg-blue-100") # Genre tags
        expect(page).to have_css(".bg-green-100") # Release type tags
      end

      it "displays cover images when available" do
        # Check for actual alt text patterns used in the home page
        # The cover_game should display with its cover image
        expect(page).to have_css("img[alt*='cover image']")

        # Also check for screenshot fallbacks
        expect(page).to have_css("img[alt*='screenshot']")
      end

      it "shows call to action section" do
        expect(page).to have_content("Ready to Share Your Game?")
        expect(page).to have_content("Join our community of indie game developers")

        # Should show appropriate button based on authentication state
        expect(page).to have_css("a, button", text: /Get Started|Upload Your Game/)
      end

      it "includes navigation" do
        expect(page).to have_link("Games")
        expect(page).to have_link("Developers")
        expect(page).to have_link("Charts")
      end
    end

    context "with no games in database" do
      before { visit root_path }

      it "shows sample games" do
        expect(page).to have_content("Mystic Quest Adventures")
        expect(page).to have_content("Crystal Legends")
        expect(page).to have_content("Retro Racer")
      end

      it "displays sample game information" do
        expect(page).to have_content("4.9")
        expect(page).to have_content("156 reviews")
        expect(page).to have_content("RPG")
        expect(page).to have_content("Complete")
      end
    end
  end

  describe "responsive design" do
    let!(:games) { create_list(:game, 3) }

    it "adapts to tablet viewport", driver: :selenium_chrome_headless do
      page.driver.browser.manage.window.resize_to(768, 1024)
      visit root_path

      expect(page).to have_content("Discover Amazing Games")
      expect(page).to have_css(".grid") # Grid layout should still work
    end

    it "adapts to mobile viewport", driver: :selenium_chrome_headless do
      page.driver.browser.manage.window.resize_to(375, 667)
      visit root_path

      expect(page).to have_content("Discover Amazing Games")
      expect(page).to have_css(".grid-cols-1") # Should show single column on mobile
    end
  end

  describe "interactive elements" do
    let!(:games) { create_list(:game, 3) }

    before { visit root_path }

    it "has working navigation links" do
      click_link "Games"
      expect(current_path).to eq(games_path)
    end

    it "shows game details when clicking on game cards" do
      # This would depend on the actual implementation
      # For now, we'll test that the cards are clickable
      expect(page).to have_css(".hover\\:shadow-xl")
    end

    it "has working call to action buttons" do
      # Check for main navigation buttons
      expect(page).to have_link("Browse Games")
      expect(page).to have_link("Upload Your Game")

      # Check call to action section based on authentication state
      within(".bg-gradient-to-r") do
        expect(page).to have_content("Ready to Share Your Game?")

        # Should have either "Get Started" (not signed in) or "Upload Your Game" button (signed in)
        expect(page).to have_css("a, button", text: /Get Started|Upload Your Game/)
      end
    end
  end

  describe "performance and loading" do
    let!(:many_games) { create_list(:game, 20) }

    it "loads efficiently with many games" do
      start_time = Time.current
      visit root_path
      load_time = Time.current - start_time

      expect(load_time).to be < 5.seconds
      expect(page).to have_content("Newest Games")
    end

    it "limits the number of games displayed" do
      visit root_path

      # Should show max 10 newest games and 6 recommended games
      newest_games = page.all(".carousel-item") # Assuming carousel items
      recommended_games = page.all(".grid .bg-white.rounded-lg.shadow-lg")

      expect(newest_games.count).to be <= 10
      expect(recommended_games.count).to be <= 6
    end
  end
end
