require "rails_helper"

RSpec.describe "Games", type: :request do
  include Rails.application.routes.url_helpers
  let(:user) { create(:user) }
  let(:staff_user) { create(:user, staff: true) }
  let(:other_user) { create(:user) }
  let(:genre) { create(:genre) }
  let(:tool) { create(:tool) }
  let(:platform) { create(:platform, name: "Windows", slug: "windows") }
  let(:game) { create(:game, user: user, genre: genre, tool: tool) }
  let(:other_users_game) { create(:game, user: other_user, genre: genre, tool: tool) }

  # Helper method to create download link attributes for testing
  def download_link_attributes(platform_ids = [])
    {
      "0" => {
        label: "Test Download",
        url: "https://example.com/download.zip",
        platform_ids: platform_ids.map(&:to_s)
      }
    }
  end

  describe "GET /games" do
    context "when games exist" do
      before do
        create_list(:game, 3, genre: genre, tool: tool)
      end

      it "returns http success" do
        get games_path(locale: :en)
        expect(response).to have_http_status(:success)
      end

      it "displays all games" do
        get games_path
        expect(response.body).to include("Games")
      end

      it "orders games by created_at desc" do
        older_game = create(:game, name: "Older Game", genre: genre, tool: tool, created_at: 1.day.ago)
        newer_game = create(:game, name: "Newer Game", genre: genre, tool: tool, created_at: 1.hour.ago)

        get games_path

        # The newer game should appear before the older game in the response
        newer_position = response.body.index("Newer Game")
        older_position = response.body.index("Older Game")
        expect(newer_position).to be < older_position
      end
    end

    context "when no games exist" do
      it "returns http success" do
        get games_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /games/:id" do
    context "when game exists" do
      it "returns http success" do
        get game_path(game)
        expect(response).to have_http_status(:success)
      end

      it "displays the game details" do
        get game_path(game)
        # Use CGI.escapeHTML to handle HTML encoding of special characters
        expect(response.body).to include(CGI.escapeHTML(game.name))
        expect(response.body).to include(game.description)
      end

      it "works with friendly_id slug" do
        get game_path(game.slug)
        expect(response).to have_http_status(:success)
        # Use CGI.escapeHTML to handle HTML encoding of special characters
        expect(response.body).to include(CGI.escapeHTML(game.name))
      end
    end

    context "when game doesn't exist" do
      it "returns 404 status" do
        get game_path("non-existent-game")
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /games/new" do
    context "when user is authenticated" do
      before { sign_in user }

      it "returns http success" do
        get new_game_path
        expect(response).to have_http_status(:success)
      end

      it "assigns a new game to current user" do
        get new_game_path
        expect(assigns(:game)).to be_a_new(Game)
        expect(assigns(:game).user).to eq(user)
      end

      it "assigns genres, tools, and platforms" do
        create(:genre, name: "Action")
        create(:tool, name: "Unity")
        create(:platform, name: "PC")

        get new_game_path

        expect(assigns(:genres)).to be_present
        expect(assigns(:tools)).to be_present
        expect(assigns(:platforms)).to be_present
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in" do
        get new_game_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /games" do
    let(:valid_attributes) do
      {
        name: "Test Game",
        description: "A test game description",
        genre_id: genre.id,
        tool_id: tool.id,
        release_type: "complete",
        adult_content: false
      }
    end

    let(:invalid_attributes) do
      {
        name: "",
        description: "",
        genre_id: nil,
        tool_id: nil
      }
    end

    context "when user is authenticated" do
      before { sign_in user }

      context "with valid parameters" do
        it "creates a new game" do
          expect {
            post games_path, params: {game: valid_attributes}
          }.to change(Game, :count).by(1)
        end

        it "assigns the game to the current user" do
          post games_path, params: {game: valid_attributes}
          expect(Game.last.user).to eq(user)
        end

        it "redirects to the created game" do
          post games_path, params: {game: valid_attributes}
          expect(response).to redirect_to(Game.last)
        end

        it "sets a success notice" do
          post games_path, params: {game: valid_attributes}
          expect(flash[:notice]).to eq("Game was successfully created.")
        end
      end

      context "with invalid parameters" do
        it "does not create a new game" do
          expect {
            post games_path, params: {game: invalid_attributes}
          }.not_to change(Game, :count)
        end

        it "renders the new template with unprocessable_entity status" do
          post games_path, params: {game: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:new)
        end

        it "assigns genres, tools, and platforms for the form" do
          # Ensure we have test data
          genre
          tool
          platform

          post games_path, params: {game: invalid_attributes}
          expect(assigns(:genres)).to be_present
          expect(assigns(:tools)).to be_present
          expect(assigns(:platforms)).to be_present
        end
      end

      context "with download links" do
        let(:attributes_with_download_links) do
          valid_attributes.merge(download_links_attributes: download_link_attributes([platform.id]))
        end

        it "creates game with download links" do
          expect {
            post "/en/games", params: {game: attributes_with_download_links}
          }.to change(Game, :count).by(1)

          game = Game.last
          expect(game.download_links.count).to eq(1)
          expect(game.download_links.first.label).to eq("Test Download")
          expect(game.download_links.first.url).to eq("https://example.com/download.zip")
          expect(game.download_links.first.platforms).to include(platform)
        end

        it "creates game with multiple download links" do
          platform2 = create(:platform, name: "Mac", slug: "mac")
          multi_download_attributes = valid_attributes.merge(
            download_links_attributes: {
              "0" => {
                label: "Windows Download",
                url: "https://example.com/windows.zip",
                platform_ids: [platform.id.to_s]
              },
              "1" => {
                label: "Mac Download",
                url: "https://example.com/mac.zip",
                platform_ids: [platform2.id.to_s]
              }
            }
          )

          expect {
            post games_path, params: {game: multi_download_attributes}
          }.to change(Game, :count).by(1)

          game = Game.last
          expect(game.download_links.count).to eq(2)
        end
      end

      context "with adult content" do
        let(:adult_game_attributes) do
          valid_attributes.merge(adult_content: true)
        end

        it "creates game with adult content flag" do
          post games_path, params: {game: adult_game_attributes}
          expect(Game.last.adult_content).to be true
        end
      end

      context "with different release types" do
        %w[complete demo minigame].each do |release_type|
          it "creates game with #{release_type} release type" do
            attributes = valid_attributes.merge(release_type: release_type)
            post games_path, params: {game: attributes}
            expect(Game.last.release_type).to eq(release_type)
          end
        end
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in" do
        post games_path, params: {game: valid_attributes}
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /games/:id/edit" do
    context "when user is the game owner" do
      before { sign_in user }

      it "returns http success" do
        get edit_game_path(game)
        expect(response).to have_http_status(:success)
      end

      it "assigns the requested game" do
        get edit_game_path(game)
        expect(assigns(:game)).to eq(game)
      end

      it "assigns genres, tools, and platforms" do
        # Ensure we have test data
        genre
        tool
        platform

        sign_in user
        get edit_game_path(game)
        expect(assigns(:genres)).to be_present
        expect(assigns(:tools)).to be_present
        expect(assigns(:platforms)).to be_present
      end
    end

    context "when user is staff" do
      before { sign_in staff_user }

      it "returns http success" do
        get edit_game_path(other_users_game)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not the game owner" do
      before { sign_in other_user }

      it "redirects to the game with alert" do
        get edit_game_path(game)
        expect(response).to redirect_to(game)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in" do
        get edit_game_path(game)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH/PUT /games/:id" do
    let(:new_attributes) do
      {
        name: "Updated Game Name",
        description: "Updated description",
        release_type: "demo"
      }
    end

    let(:invalid_attributes) do
      {
        name: "",
        description: ""
      }
    end

    context "when user is the game owner" do
      before { sign_in user }

      context "with valid parameters" do
        it "updates the requested game" do
          patch game_path(game), params: {game: new_attributes}
          game.reload
          expect(game.name).to eq("Updated Game Name")
          expect(game.description).to eq("Updated description")
          expect(game.release_type).to eq("demo")
        end

        it "redirects to the game" do
          patch game_path(game), params: {game: new_attributes}
          expect(response).to redirect_to(game)
        end

        it "sets a success notice" do
          patch game_path(game), params: {game: new_attributes}
          expect(flash[:notice]).to eq("Game was successfully updated.")
        end
      end

      context "with invalid parameters" do
        it "does not update the game" do
          original_name = game.name
          patch game_path(game), params: {game: invalid_attributes}
          game.reload
          expect(game.name).to eq(original_name)
        end

        it "renders the edit template with unprocessable_entity status" do
          patch game_path(game), params: {game: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:edit)
        end

        it "assigns genres, tools, and platforms for the form" do
          # Ensure we have test data
          genre
          tool
          platform

          sign_in user
          patch game_path(game), params: {game: invalid_attributes}
          expect(assigns(:genres)).to be_present
          expect(assigns(:tools)).to be_present
          expect(assigns(:platforms)).to be_present
        end
      end
    end

    context "when user is staff" do
      before { sign_in staff_user }

      it "allows updating other users' games" do
        patch game_path(other_users_game), params: {game: new_attributes}
        other_users_game.reload
        expect(other_users_game.name).to eq("Updated Game Name")
        expect(response).to redirect_to(other_users_game)
      end
    end

    context "when user is not the game owner" do
      before { sign_in other_user }

      it "redirects to the game with alert" do
        patch game_path(game), params: {game: new_attributes}
        expect(response).to redirect_to(game)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end

      it "does not update the game" do
        original_name = game.name
        patch game_path(game), params: {game: new_attributes}
        game.reload
        expect(game.name).to eq(original_name)
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in" do
        patch game_path(game), params: {game: new_attributes}
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /games/:id" do
    context "when user is the game owner" do
      before { sign_in user }

      it "destroys the requested game" do
        game # Create the game
        expect {
          delete game_path(game)
        }.to change(Game, :count).by(-1)
      end

      it "redirects to the games list" do
        delete game_path(game)
        expect(response).to redirect_to(games_path)
      end

      it "sets a success notice" do
        delete game_path(game)
        expect(flash[:notice]).to eq("Game was successfully deleted.")
      end
    end

    context "when user is staff" do
      before { sign_in staff_user }

      it "allows deleting other users' games" do
        other_users_game # Create the game
        expect {
          delete game_path(other_users_game)
        }.to change(Game, :count).by(-1)
      end
    end

    context "when user is not the game owner" do
      before { sign_in other_user }

      it "redirects to the game with alert" do
        delete game_path(game)
        expect(response).to redirect_to(game)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end

      it "does not destroy the game" do
        game # Create the game
        expect {
          delete game_path(game)
        }.not_to change(Game, :count)
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in" do
        delete game_path(game)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "private methods" do
    describe "#set_game" do
      it "finds game by friendly_id" do
        sign_in user
        get game_path(game.slug)
        expect(assigns(:game)).to eq(game)
      end
    end

    describe "#check_game_owner" do
      context "when user is not owner and not staff" do
        before { sign_in other_user }

        it "redirects with alert message" do
          get edit_game_path(game)
          expect(response).to redirect_to(game)
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end
      end

      context "when user is staff but not owner" do
        before { sign_in staff_user }

        it "allows access" do
          get edit_game_path(other_users_game)
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
