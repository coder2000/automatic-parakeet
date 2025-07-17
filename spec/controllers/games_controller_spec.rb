require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user) }
  let(:genre) { create(:genre) }
  let(:tool) { create(:tool) }
  let(:game) { create(:game, user: user) }
  let(:valid_attributes) do
    {
      name: 'Test Game',
      description: 'A test game description',
      genre_id: genre.id,
      tool_id: tool.id,
      release_type: 'complete'
    }
  end
  let(:invalid_attributes) do
    {
      name: '',
      description: ''
    }
  end

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @games" do
      get :index
      expect(assigns(:games)).to be_present
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: game.to_param }
      expect(response).to be_successful
    end

    it "assigns the requested game" do
      get :show, params: { id: game.to_param }
      expect(assigns(:game)).to eq(game)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new game" do
      get :new
      expect(assigns(:game)).to be_a_new(Game)
    end

    it "assigns genres and tools" do
      get :new
      expect(assigns(:genres)).to be_present
      expect(assigns(:tools)).to be_present
      expect(assigns(:platforms)).to be_present
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { id: game.to_param }
      expect(response).to be_successful
    end

    it "assigns the requested game" do
      get :edit, params: { id: game.to_param }
      expect(assigns(:game)).to eq(game)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Game" do
        expect {
          post :create, params: { game: valid_attributes }
        }.to change(Game, :count).by(1)
      end

      it "assigns the game to the current user" do
        post :create, params: { game: valid_attributes }
        expect(assigns(:game).user).to eq(user)
      end

      it "redirects to the created game" do
        post :create, params: { game: valid_attributes }
        expect(response).to redirect_to(Game.last)
      end

      context "with media attributes" do
        let(:screenshot_file) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
        let(:video_file) { fixture_file_upload('spec/fixtures/test_video.mp4', 'video/mp4') }
        let(:media_attributes) do
          {
            "0" => {
              media_type: 'screenshot',
              title: 'Test Screenshot',
              file: screenshot_file
            },
            "1" => {
              media_type: 'video',
              title: 'Test Video',
              file: video_file
            }
          }
        end

        it "creates game with media" do
          expect {
            post :create, params: { 
              game: valid_attributes.merge(media_attributes: media_attributes)
            }
          }.to change(Game, :count).by(1)
            .and change(Medium, :count).by(2)
        end
      end

      context "with cover image" do
        let(:game_with_screenshot) { create(:game, user: user) }
        let(:screenshot) { create(:medium, :screenshot, mediable: game_with_screenshot) }

        it "sets cover image when provided" do
          post :create, params: { 
            game: valid_attributes.merge(cover_image_id: screenshot.id)
          }
          expect(assigns(:game).cover_image).to eq(screenshot)
        end
      end
    end

    context "with invalid params" do
      it "does not create a new Game" do
        expect {
          post :create, params: { game: invalid_attributes }
        }.to change(Game, :count).by(0)
      end

      it "renders the new template" do
        post :create, params: { game: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        {
          name: 'Updated Game Name',
          description: 'Updated description'
        }
      end

      it "updates the requested game" do
        put :update, params: { id: game.to_param, game: new_attributes }
        game.reload
        expect(game.name).to eq('Updated Game Name')
        expect(game.description).to eq('Updated description')
      end

      it "redirects to the game" do
        put :update, params: { id: game.to_param, game: new_attributes }
        expect(response).to redirect_to(game)
      end

      context "with cover image update" do
        let(:screenshot) { create(:medium, :screenshot, mediable: game) }

        it "updates cover image" do
          put :update, params: { 
            id: game.to_param, 
            game: { cover_image_id: screenshot.id }
          }
          game.reload
          expect(game.cover_image).to eq(screenshot)
        end
      end
    end

    context "with invalid params" do
      it "renders the edit template" do
        put :update, params: { id: game.to_param, game: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested game" do
      game # create the game
      expect {
        delete :destroy, params: { id: game.to_param }
      }.to change(Game, :count).by(-1)
    end

    it "redirects to the games list" do
      delete :destroy, params: { id: game.to_param }
      expect(response).to redirect_to(games_url)
    end
  end

  describe "authorization" do
    let(:other_user) { create(:user) }
    let(:other_game) { create(:game, user: other_user) }

    it "prevents editing other user's games" do
      get :edit, params: { id: other_game.to_param }
      expect(response).to redirect_to(root_path)
    end

    it "prevents updating other user's games" do
      put :update, params: { id: other_game.to_param, game: valid_attributes }
      expect(response).to redirect_to(root_path)
    end

    it "prevents deleting other user's games" do
      delete :destroy, params: { id: other_game.to_param }
      expect(response).to redirect_to(root_path)
    end
  end
end