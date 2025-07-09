require "rails_helper"

RSpec.describe "Charts", type: :request do
  describe "GET /charts" do
    it "returns http success" do
      get charts_path
      expect(response).to have_http_status(:success)
    end

    it "displays the charts page" do
      get charts_path
      expect(response.body).to include("Game Charts")
      expect(response.body).to include("Most Voted")
      expect(response.body).to include("Highest Rated")
      expect(response.body).to include("Most Download Options")
      expect(response.body).to include("Newest Games")
    end

    context "with games data" do
      let!(:user) { create(:user) }
      let!(:rpg_genre) { create(:genre, name: "RPG", key: "rpg") }
      let!(:puzzle_genre) { create(:genre, name: "Puzzle", key: "puzzle") }
      let!(:tool) { create(:tool) }
      let!(:platform) { create(:platform) }

      let!(:highly_rated_rpg) do
        game = create(:game, user: user, genre: rpg_genre, tool: tool, name: "Highly Rated RPG")
        5.times { create(:rating, game: game, user: create(:user), rating: 5) }
        game.reload
      end

      let!(:most_voted_puzzle) do
        game = create(:game, user: user, genre: puzzle_genre, tool: tool, name: "Most Voted Puzzle")
        10.times { create(:rating, game: game, user: create(:user), rating: 4) }
        game.reload
      end

      let!(:rpg_with_downloads) do
        game = create(:game, user: user, genre: rpg_genre, tool: tool, name: "RPG with Downloads")
        3.times { create(:download_link, game: game, platforms: [platform]) }
        game
      end

      it "shows games in the charts" do
        get charts_path

        expect(response.body).to include("Highly Rated RPG")
        expect(response.body).to include("Most Voted Puzzle")
        expect(response.body).to include("RPG with Downloads")
      end

      it "shows genre filter options" do
        get charts_path

        expect(response.body).to include("Filter by genre:")
        expect(response.body).to include("All Genres")
        expect(response.body).to include("RPG")
        expect(response.body).to include("Puzzle")
      end

      it "filters games by genre" do
        get charts_path(genre_id: rpg_genre.id)

        expect(response.body).to include("Highly Rated RPG")
        expect(response.body).to include("RPG with Downloads")
        expect(response.body).not_to include("Most Voted Puzzle")
        expect(response.body).to include("Top games in the RPG genre")
      end

      it "shows all games when no genre filter is applied" do
        get charts_path

        expect(response.body).to include("Highly Rated RPG")
        expect(response.body).to include("Most Voted Puzzle")
        expect(response.body).to include("RPG with Downloads")
      end
    end
  end
end
