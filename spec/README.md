# Test Suite Documentation

This directory contains comprehensive tests for the Rails application, covering all major features including media upload, cover image selection, and game management.

## Test Structure

```
spec/
├── controllers/          # Controller tests
├── features/            # Feature tests (user workflows)
├── fixtures/            # Test fixtures and sample files
├── integration/         # Integration tests (full workflows)
├── javascript/          # JavaScript/Stimulus controller tests
├── models/              # Model tests (validations, associations)
├── requests/            # Request tests (HTTP endpoints)
├── support/             # Test configuration and helpers
├── system/              # System tests (browser-based)
└── views/               # View tests (if needed)
```

## Running Tests

### All Tests

```bash
# Run the complete test suite
bin/test

# Or use RSpec directly
bundle exec rspec
```

### Specific Test Types

```bash
# Model tests only
bundle exec rspec spec/models/

# Controller tests only
bundle exec rspec spec/controllers/

# System tests (browser-based)
bundle exec rspec spec/system/

# JavaScript tests
bundle exec rspec spec/javascript/

# Integration tests
bundle exec rspec spec/integration/
```

### Specific Features

```bash
# Game upload functionality
bundle exec rspec spec/system/game_upload_spec.rb

# Cover image selection
bundle exec rspec spec/features/cover_image_selection_spec.rb

# Media upload flow
bundle exec rspec spec/integration/media_upload_flow_spec.rb

# Home page functionality
bundle exec rspec spec/system/home_page_spec.rb
```

### Test Options

```bash
# Run with documentation format
bundle exec rspec --format documentation

# Run specific test by line number
bundle exec rspec spec/models/game_spec.rb:45

# Run tests matching a pattern
bundle exec rspec --grep "cover image"

# Run tests with specific metadata
bundle exec rspec --tag js
bundle exec rspec --tag slow
```

## Test Configuration

### Database Cleaner

- **Transaction strategy**: Used for most tests (faster)
- **Truncation strategy**: Used for JavaScript and system tests
- **Automatic cleanup**: Database is cleaned between tests

### Test Types and Strategies

| Test Type | Database Strategy | JavaScript | Browser |
|-----------|------------------|------------|---------|
| Model | Transaction | No | No |
| Controller | Transaction | No | No |
| Request | Transaction | No | No |
| Feature | Truncation | Optional | Yes |
| System | Truncation | Yes | Yes |
| Integration | Truncation | Optional | Optional |

### Test Environment Setup

The test suite automatically:

- Sets up the test database
- Runs pending migrations
- Seeds essential test data (genres, tools, platforms)
- Configures Active Storage for testing
- Sets up Capybara for browser testing

## Key Test Features

### Comprehensive Model Testing

- **Validations**: All model validations are tested
- **Associations**: Polymorphic and standard associations
- **Counter Culture**: Counter cache functionality
- **File Attachments**: Active Storage file handling
- **Business Logic**: Custom methods and scopes

### Controller Testing

- **CRUD Operations**: Create, read, update, delete
- **Authorization**: User ownership and permissions
- **File Uploads**: Media attachment processing
- **Error Handling**: Validation errors and edge cases

### System Testing

- **User Workflows**: Complete user interactions
- **JavaScript**: Stimulus controller functionality
- **Responsive Design**: Multiple device sizes
- **File Uploads**: Drag-and-drop and manual upload
- **Form Interactions**: Dynamic field management

### Integration Testing

- **End-to-End Workflows**: Complete feature flows
- **Database Consistency**: Counter cache accuracy
- **Performance**: Large dataset handling
- **Error Recovery**: Form state preservation

## Test Data and Factories

### Factories (FactoryBot)

```ruby
# Create a game with media
game = create(:game)
screenshot = create(:medium, :screenshot, mediable: game)
video = create(:medium, :video, mediable: game)

# Create game with cover image
game_with_cover = create(:game)
screenshot = create(:medium, :screenshot, mediable: game_with_cover)
game_with_cover.update(cover_image: screenshot)
```

### Shared Contexts

```ruby
# Use predefined contexts
include_context "with authenticated user"
include_context "with game and media"
include_context "with cover image"
include_context "with platforms and tools"
```

### Test Helpers

```ruby
# Create test files
image_file = create_test_image('screenshot.jpg')
video_file = create_test_video('trailer.mp4')

# Setup test data
setup_test_data  # Creates user, genre, tool, platform

# Clean up
cleanup_test_data
```

## JavaScript Testing

### Stimulus Controllers

- **Drag Drop Upload**: File validation and upload
- **Cover Image**: Selection and visual feedback
- **Media Fields**: Dynamic field management
- **Download Links**: Link management

### Test Structure

```javascript
describe("DragDropUploadController", () => {
  // Setup and teardown
  beforeEach(() => { /* setup */ })
  afterEach(() => { /* cleanup */ })

  // Test categories
  describe("initialization", () => { /* ... */ })
  describe("file validation", () => { /* ... */ })
  describe("drag and drop events", () => { /* ... */ })
})
```

## Performance Testing

### Load Testing

- Tests with maximum allowed media (6 screenshots, 3 videos)
- Large dataset handling
- Page load time verification
- Memory usage monitoring

### Optimization Verification

- Counter cache accuracy
- Database query efficiency
- File upload performance
- Responsive design speed

## Debugging Tests

### Common Issues

```bash
# Database not clean between tests
bundle exec rspec --tag clean_slate

# JavaScript not working
bundle exec rspec --tag js --format documentation

# File upload issues
bundle exec rspec spec/system/ --tag active_storage
```

### Debugging Tools

- `binding.pry` for interactive debugging
- `save_and_open_page` for Capybara screenshots
- `puts` statements for simple debugging
- RSpec metadata for test categorization

## Continuous Integration

### Test Commands for CI

```bash
# Setup
bin/test --setup

# Run all tests
bin/test

# Run with coverage
COVERAGE=true bin/test

# Run linting
bin/test --lint
```

### Required Environment

- Ruby 3.x
- Rails 8.x
- PostgreSQL (or SQLite for testing)
- Chrome/Chromium for system tests
- Node.js for JavaScript tests

## Test Coverage

The test suite aims for comprehensive coverage of:

- ✅ Model validations and associations
- ✅ Controller actions and authorization
- ✅ User workflows and interactions
- ✅ JavaScript functionality
- ✅ File upload and media management
- ✅ Cover image selection
- ✅ Responsive design
- ✅ Error handling and edge cases

## Contributing

When adding new features:

1. Write tests first (TDD approach)
2. Include model, controller, and system tests
3. Test both happy path and error cases
4. Add JavaScript tests for Stimulus controllers
5. Update this documentation if needed

### Test Naming Conventions

- Use descriptive test names
- Group related tests with `describe` blocks
- Use `context` for different scenarios
- Use `it` for specific behaviors

### Example Test Structure

```ruby
RSpec.describe Game, type: :model do
  describe "validations" do
    context "when media limits are exceeded" do
      it "rejects more than 6 screenshots" do
        # Test implementation
      end
    end
  end
end
```
