# config/initializers/dartsass.rb
Rails.application.config.dartsass.builds = {
  "#{Rails.root}/app/assets/stylesheets/active_admin.scss" => "#{Rails.root}/app/assets/builds/active_admin.css"
}
