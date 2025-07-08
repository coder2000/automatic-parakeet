require "ostruct"

class HomeController < ApplicationController
  def index
    @newest_games = Game.includes(:genre, :tool, :user)
      .order(created_at: :desc)
      .limit(10)

    # Fallback sample data if no games exist
    if @newest_games.blank?
      @newest_games = create_sample_games
    end
  end

  private

  def create_sample_games
    [
      OpenStruct.new(
        name: "Mystic Quest Adventures",
        description: "Embark on an epic journey through mystical lands filled with ancient secrets and powerful magic. Battle fierce creatures, solve intricate puzzles, and uncover the truth behind the lost civilization.",
        release_type: "complete",
        rating_avg: 4.5,
        rating_count: 127,
        genre: OpenStruct.new(name: "Adventure"),
        tool: OpenStruct.new(name: "Unity"),
        user: OpenStruct.new(given_name: "John", surname: "Developer")
      ),
      OpenStruct.new(
        name: "Neon Runner 2084",
        description: "Race through cyberpunk cityscapes in this high-octane endless runner. Dodge obstacles, collect power-ups, and compete for the highest score in a futuristic world.",
        release_type: "complete",
        rating_avg: 4.2,
        rating_count: 89,
        genre: OpenStruct.new(name: "Action"),
        tool: OpenStruct.new(name: "Godot"),
        user: OpenStruct.new(given_name: "Sarah", surname: "GameDev")
      ),
      OpenStruct.new(
        name: "Puzzle Master Pro",
        description: "Challenge your mind with over 200 hand-crafted puzzles ranging from simple brain teasers to complex logic challenges. Perfect for puzzle enthusiasts of all skill levels.",
        release_type: "demo",
        rating_avg: 4.8,
        rating_count: 203,
        genre: OpenStruct.new(name: "Puzzle"),
        tool: OpenStruct.new(name: "GameMaker"),
        user: OpenStruct.new(given_name: "Mike", surname: "Puzzler")
      )
    ]
  end
end
