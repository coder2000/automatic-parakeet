# Test helper methods for RSpec

module TestHelpers
  # Helper to create a test file for uploads
  def create_test_file(filename: "test.jpg", content_type: "image/jpeg", content: "test content")
    file = Tempfile.new([filename.split(".").first, ".#{filename.split(".").last}"])
    file.write(content)
    file.rewind

    ActionDispatch::Http::UploadedFile.new(
      tempfile: file,
      filename: filename,
      type: content_type
    )
  end

  # Helper to create test image file
  def create_test_image(filename: "test.jpg")
    create_test_file(
      filename: filename,
      content_type: "image/jpeg",
      content: "\xFF\xD8\xFF\xE0\x00\x10JFIF" # Minimal JPEG header
    )
  end

  # Helper to create test video file
  def create_test_video(filename: "test.mp4")
    create_test_file(
      filename: filename,
      content_type: "video/mp4",
      content: "\x00\x00\x00\x20ftypmp42" # Minimal MP4 header
    )
  end

  # Helper to wait for database operations to complete
  def wait_for_database
    sleep 0.1 # Small delay to ensure database operations complete
  end

  # Helper to ensure counter caches are accurate
  def refresh_counter_caches
    Game.find_each do |game|
      game.update_columns(
        screenshots_count: game.screenshots.count,
        videos_count: game.videos.count
      )
    end
  end

  # Helper to clean Active Storage attachments
  def clean_active_storage
    ActiveStorage::Attachment.all.each do |attachment|
      attachment.purge_later
    end
    ActiveStorage::Blob.unattached.find_each(&:purge_later)
  end

  # Helper to simulate file upload in tests
  def attach_file_to_medium(medium, file_type: :image)
    case file_type
    when :image
      medium.file.attach(
        io: StringIO.new("fake image data"),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
    when :video
      medium.file.attach(
        io: StringIO.new("fake video data"),
        filename: "test.mp4",
        content_type: "video/mp4"
      )
    end
  end

  # Helper to create game with media for testing
  def create_game_with_media(user: nil, screenshots_count: 2, videos_count: 1, with_cover: false)
    user ||= create(:user)
    game = create(:game, user: user)

    screenshots = []
    screenshots_count.times do |i|
      screenshot = create(:medium, :screenshot, mediable: game, position: i)
      attach_file_to_medium(screenshot, file_type: :image)
      screenshots << screenshot
    end

    videos_count.times do |i|
      video = create(:medium, :video, mediable: game, position: i)
      attach_file_to_medium(video, file_type: :video)
    end

    # Set cover image if requested and screenshots exist
    if with_cover && screenshots.any?
      game.update!(cover_image: screenshots.first)
    end

    game.reload
    game
  end

  # Helper to verify database is clean
  def verify_database_clean
    expect(Game.count).to eq(0)
    expect(Medium.count).to eq(0)
    expect(User.count).to eq(0)
    expect(ActiveStorage::Attachment.count).to eq(0)
    expect(ActiveStorage::Blob.count).to eq(0)
  end

  # Helper to setup test data with proper relationships
  def setup_test_data
    @user = create(:user)
    @genre = create(:genre)
    @tool = create(:tool)
    @platform = create(:platform)
  end

  # Helper to clean up test data
  def cleanup_test_data
    clean_active_storage
    DatabaseCleaner.clean_with(:truncation)
  end
end

RSpec.configure do |config|
  config.include TestHelpers

  # Ensure clean state for specific test types
  config.before(:each, :clean_slate) do
    cleanup_test_data
  end

  config.after(:each, :clean_slate) do
    cleanup_test_data
  end
end
