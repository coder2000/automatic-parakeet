# Website Logo Feature

This feature allows staff members to upload and manage a custom website logo with alt text through the ActiveAdmin interface.

## Overview

The website logo feature consists of:

1. **SiteSettings Model** - A singleton model that stores the logo and alt text
2. **ActiveAdmin Interface** - Admin panel for managing the logo and alt text
3. **Helper Methods** - Easy access to logo settings from views
4. **Navigation Integration** - Updated navigation to use the configurable logo

## Features

- **Uploadable Logo**: Staff can upload custom logo images (JPEG, PNG, GIF, WebP, SVG)
- **Alt Text Management**: Staff can set and update the logo's alt text for accessibility
- **Fallback Support**: If no custom logo is uploaded, the system uses the default logo from assets
- **File Validation**: 
  - Supports multiple image formats
  - Maximum file size of 5MB
  - Content type validation
- **Singleton Pattern**: Only one set of site settings can exist
- **Admin Interface**: User-friendly interface with logo preview

## File Structure

```
app/
├── models/
│   └── site_settings.rb              # Main model for site settings
├── admin/
│   └── site_settings.rb              # ActiveAdmin configuration
├── helpers/
│   └── application_helper.rb          # Helper methods for accessing logo
└── views/
    └── shared/
        └── _navigation.html.erb       # Updated to use configurable logo

db/
└── migrate/
    └── 20250804005000_create_site_settings.rb  # Migration

spec/
└── models/
    └── site_settings_spec.rb          # Comprehensive tests
```

## Usage

### For Staff (Admin Interface)

1. Navigate to the admin panel (`/admin`)
2. Click on "Site Settings" in the menu
3. Upload a new logo image and/or update the alt text
4. Click "Update Site Settings" to save changes

### For Developers (In Views)

Use the helper methods in your views:

```erb
<!-- Get the logo URL (either custom or default fallback) -->
<%= image_tag site_logo_url, alt: site_logo_alt_text %>

<!-- Or access the site settings directly -->
<% if site_settings.custom_logo? %>
  <p>Using custom logo</p>
<% else %>
  <p>Using default logo</p>
<% end %>
```

### For Developers (In Controllers/Models)

```ruby
# Access the singleton instance
settings = SiteSettings.main

# Check if custom logo is uploaded
settings.custom_logo?

# Get logo URL (with fallback)
settings.logo_url

# Get alt text
settings.logo_alt_text
```

## API Reference

### SiteSettings Model

#### Class Methods
- `SiteSettings.main` - Returns the singleton instance (creates if doesn't exist)

#### Instance Methods
- `logo_url` - Returns the logo URL (custom or default fallback)
- `custom_logo?` - Returns true if a custom logo is attached
- `logo_alt_text` - Returns the alt text for the logo

#### Validations
- `logo_alt_text` must be present and max 255 characters
- `logo` must be a valid image format (JPEG, PNG, GIF, WebP, SVG)
- `logo` must be less than 5MB
- Only allows ID of 'main' (singleton pattern)

### Helper Methods

Available in all views via `ApplicationHelper`:

- `site_settings` - Returns the SiteSettings instance
- `site_logo_url` - Returns the logo URL
- `site_logo_alt_text` - Returns the logo alt text

## Technical Details

### Database Schema

```sql
CREATE TABLE site_settings (
    id VARCHAR PRIMARY KEY,           -- Always 'main'
    logo_alt_text VARCHAR NOT NULL,   -- Alt text for the logo
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

The logo itself is stored using Rails Active Storage.

### Singleton Pattern

The SiteSettings model implements a singleton pattern to ensure only one set of site-wide settings exists. This prevents confusion and ensures consistency across the application.

### Default Fallback

If no custom logo is uploaded, the system automatically falls back to the existing logo at `app/assets/images/logo/logo.png`.

### Security

- File upload validation prevents malicious file types
- File size limits prevent DoS attacks
- Only staff members can access the admin interface
- SQL injection protection through ActiveRecord

## Testing

Run the comprehensive test suite:

```bash
bundle exec rspec spec/models/site_settings_spec.rb
```

The tests cover:
- Model validations
- Singleton pattern enforcement
- Logo URL generation
- File format validation
- File size limits
- Alt text requirements

## Migration

The migration automatically:
1. Creates the site_settings table
2. Inserts the default record with ID 'main'
3. Sets default alt text to 'Website Logo'

To run the migration:

```bash
rails db:migrate
```

## Rollback

To rollback this feature:

```bash
rails db:rollback
```

Then remove the created files:
- `app/models/site_settings.rb`
- `app/admin/site_settings.rb`
- `spec/models/site_settings_spec.rb`
- Restore original navigation template

## Future Enhancements

Potential improvements for this feature:

1. **Multiple Logo Variants**: Support for different logo sizes/versions
2. **Mobile Logo**: Separate logo configuration for mobile views
3. **Logo Position**: Configurable logo positioning/alignment
4. **Favicon Management**: Extend to manage favicons as well
5. **Logo History**: Keep track of previous logos
6. **Logo Analytics**: Track logo performance/clicks

## Support

For questions or issues with this feature, contact the development team or create an issue in the project repository.
