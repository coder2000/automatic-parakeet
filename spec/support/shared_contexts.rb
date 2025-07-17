# Shared contexts for RSpec tests

RSpec.shared_context "with authenticated user" do
  let(:user) { create(:user) }

  before do
    sign_in user if respond_to?(:sign_in)
  end
end

RSpec.shared_context "with game and media" do
  include_context "with authenticated user"

  let(:genre) { create(:genre) }
  let(:tool) { create(:tool) }
  let(:game) { create(:game, user: user, genre: genre, tool: tool) }
  let!(:screenshot1) { create(:medium, :screenshot, mediable: game, position: 0, title: "Main Menu") }
  let!(:screenshot2) { create(:medium, :screenshot, mediable: game, position: 1, title: "Gameplay") }
  let!(:video) { create(:medium, :video, mediable: game, position: 0, title: "Trailer") }

  before do
    # Attach files to media
    screenshot1.file.attach(
      io: StringIO.new("fake image data"),
      filename: "screenshot1.jpg",
      content_type: "image/jpeg"
    )

    screenshot2.file.attach(
      io: StringIO.new("fake image data"),
      filename: "screenshot2.jpg",
      content_type: "image/jpeg"
    )

    video.file.attach(
      io: StringIO.new("fake video data"),
      filename: "video.mp4",
      content_type: "video/mp4"
    )

    game.reload
  end
end

RSpec.shared_context "with cover image" do
  include_context "with game and media"

  before do
    game.update(cover_image: screenshot1)
  end
end

RSpec.shared_context "with platforms and tools" do
  let!(:windows_platform) { create(:platform, name: "Windows") }
  let!(:mac_platform) { create(:platform, name: "macOS") }
  let!(:linux_platform) { create(:platform, name: "Linux") }
  let!(:unity_tool) { create(:tool, name: "Unity") }
  let!(:godot_tool) { create(:tool, name: "Godot") }
  let!(:rpg_genre) { create(:genre, name: "RPG") }
  let!(:action_genre) { create(:genre, name: "Action") }
end

RSpec.shared_context "with sample games" do
  include_context "with platforms and tools"
  include_context "with authenticated user"

  let!(:published_game) do
    game = create(:game,
      user: user,
      genre: rpg_genre,
      tool: unity_tool,
      name: "Published Game",
      published: true,
      rating_avg: 4.5,
      rating_count: 10)

    # Add media to published game
    screenshot = create(:medium, :screenshot, mediable: game, title: "Published Screenshot")
    screenshot.file.attach(
      io: StringIO.new("fake image data"),
      filename: "published.jpg",
      content_type: "image/jpeg"
    )

    game.update!(cover_image: screenshot)
    game
  end

  let!(:unpublished_game) do
    create(:game,
      user: user,
      genre: action_genre,
      tool: godot_tool,
      name: "Unpublished Game",
      published: false)
  end
end

RSpec.shared_context "with javascript", :js do
  # This context is used to mark tests that require JavaScript
  # The :js metadata will trigger the appropriate Capybara driver
end

RSpec.shared_context "with clean database", :clean_slate do
  # This context ensures a completely clean database state
  before do
    DatabaseCleaner.clean_with(:truncation)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end
end

RSpec.shared_context "with file uploads" do
  let(:valid_image_file) do
    fixture_file_upload("spec/fixtures/test_image.jpg", "image/jpeg")
  end

  let(:valid_video_file) do
    fixture_file_upload("spec/fixtures/test_video.mp4", "video/mp4")
  end

  let(:invalid_file) do
    fixture_file_upload("spec/fixtures/test_document.txt", "text/plain")
  end

  before do
    # Ensure fixture files exist
    FileUtils.mkdir_p(Rails.root.join("spec", "fixtures"))

    # Create minimal test files if they don't exist
    unless File.exist?(Rails.root.join("spec", "fixtures", "test_image.jpg"))
      File.write(Rails.root.join("spec", "fixtures", "test_image.jpg"), "\xFF\xD8\xFF\xE0")
    end

    unless File.exist?(Rails.root.join("spec", "fixtures", "test_video.mp4"))
      File.write(Rails.root.join("spec", "fixtures", "test_video.mp4"), "\x00\x00\x00\x20ftyp")
    end

    unless File.exist?(Rails.root.join("spec", "fixtures", "test_document.txt"))
      File.write(Rails.root.join("spec", "fixtures", "test_document.txt"), "This is a text file")
    end
  end
end
