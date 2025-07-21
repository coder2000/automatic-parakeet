# Helper methods specifically for cover image testing

module CoverImageTestHelpers
  # Create a game with a properly associated cover image
  def create_game_with_cover_image(user: nil, **game_attributes)
    user ||= create(:user)
    game = create(:game, {user: user}.merge(game_attributes))

    # Create a screenshot that belongs to this game
    screenshot = create(:medium, :screenshot, mediable: game, title: "Cover Image")
    screenshot.file.attach(
      io: StringIO.new("fake image data"),
      filename: "cover.jpg",
      content_type: "image/jpeg"
    )

    # Set it as the cover image
    game.update!(cover_image: screenshot)
    game.reload
    game
  end

  # Create multiple games with cover images for testing
  def create_games_with_covers(count: 3, user: nil)
    user ||= create(:user)

    count.times.map do |i|
      create_game_with_cover_image(
        user: user,
        name: "Game with Cover #{i + 1}",
        rating_avg: 4.0 + (i * 0.2),
        rating_count: 10 + i
      )
    end
  end

  # Verify cover image relationship is valid
  def expect_valid_cover_image(game)
    expect(game.cover_image).to be_present
    expect(game.cover_image.mediable).to eq(game)
    expect(game.cover_image.screenshot?).to be true
    expect(game.cover_image.file).to be_attached
  end

  # Create a game with multiple screenshots and set one as cover
  def create_game_with_multiple_screenshots_and_cover(screenshots_count: 3, user: nil)
    user ||= create(:user)
    game = create(:game, user: user)

    screenshots = screenshots_count.times.map do |i|
      screenshot = create(:medium, :screenshot, mediable: game, position: i, title: "Screenshot #{i + 1}")
      screenshot.file.attach(
        io: StringIO.new("fake image data #{i}"),
        filename: "screenshot_#{i + 1}.jpg",
        content_type: "image/jpeg"
      )
      screenshot
    end

    # Set the first screenshot as cover image
    game.update!(cover_image: screenshots.first)
    game.reload
    game
  end

  # Test cover image validation scenarios
  def test_cover_image_validation(game)
    # Test with valid screenshot from same game
    valid_screenshot = create(:medium, :screenshot, mediable: game)
    game.cover_image = valid_screenshot
    expect(game).to be_valid

    # Test with video (should be invalid)
    video = create(:medium, :video, mediable: game)
    game.cover_image = video
    expect(game).not_to be_valid
    expect(game.errors[:cover_image]).to include("must be a screenshot")

    # Test with screenshot from different game
    other_game = create(:game)
    other_screenshot = create(:medium, :screenshot, mediable: other_game)
    game.cover_image = other_screenshot
    expect(game).not_to be_valid
    expect(game.errors[:cover_image]).to include("must belong to this game")

    # Test with nil (should be valid)
    game.cover_image = nil
    expect(game).to be_valid
  end
end

RSpec.configure do |config|
  config.include CoverImageTestHelpers
end
