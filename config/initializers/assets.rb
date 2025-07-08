# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets for ActiveAdmin
Rails.application.config.assets.precompile += %w[active_admin.css active_admin.js active_admin.scss]

# Ensure JavaScript files are served with correct MIME type
Rails.application.config.assets.configure do |env|
  env.register_mime_type "text/javascript", extensions: [".js"]
end
