namespace :counter_culture do
  desc "Fix counter cache counts for media"
  task fix_counts: :environment do
    puts "Fixing counter cache counts for media..."

    # Fix screenshots_count and videos_count for all games
    Game.find_each do |game|
      screenshots_count = game.media.where(media_type: "screenshot").count
      videos_count = game.media.where(media_type: "video").count

      game.update_columns(
        screenshots_count: screenshots_count,
        videos_count: videos_count
      )

      puts "Updated Game #{game.id}: #{screenshots_count} screenshots, #{videos_count} videos"
    end

    puts "Counter cache fix completed!"
  end

  desc "Initialize counter caches for existing records"
  task initialize: :environment do
    puts "Initializing counter caches..."

    # Use counter_culture's built-in fix method
    Medium.counter_culture_fix_counts

    puts "Counter cache initialization completed!"
  end
end
