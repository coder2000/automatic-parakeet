# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }
  let(:other_user) { create(:user) }
  
  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end
    
    it "assigns games" do
      game # create the game
      get :index
      expect(assigns(:games)).to include(game)
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { id: game.to_param }
      expect(response).to be_successful
    end
    
    it "assigns the requested game" do
      get :show, params: { id: game.to_param }
      expect(assigns(:game)).to eq(game)
    end
  end

  describe "GET #new" do
    context "when user is signed in" do
      before { sign_in user }
      
      it "returns a successful response" do
        get :new
        expect(response).to be_successful
      end
      
      it "assigns a new game" do
        get :new
        expect(assigns(:game)).to be_a_new(Game)
      end
    end
    
    context "when user is not signed in" do
      it "redirects to sign in" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST #create" do
    context "when user is signed in" do
      before { sign_in user }
      
      context "with valid parameters" do
        let(:valid_attributes) do
          {
            name: "Test Game",
            description: "A test game description that is long enough to meet validation requirements",
            genre_id: create(:genre).id,
            tool_id: create(:tool).id,
            game_languages_attributes: {
              '0' => { language_code: 'en' }
            }
          }
        end
        
        it "creates a new game" do
          expect {
            post :create, params: { game: valid_attributes }
          }.to change(Game, :count).by(1)
        end
        
        it "redirects to the created game" do
          post :create, params: { game: valid_attributes }
          expect(response).to redirect_to(Game.last)
        end
      end
      
      context "with invalid parameters" do
        let(:invalid_attributes) do
          {
            name: "",
            description: "Too short"
          }
        end
        
        it "does not create a new game" do
          expect {
            post :create, params: { game: invalid_attributes }
          }.not_to change(Game, :count)
        end
        
        it "renders the new template" do
          post :create, params: { game: invalid_attributes }
          expect(response).to render_template(:new)
        end
      end
    end
    
    context "when user is not signed in" do
      it "redirects to sign in" do
        post :create, params: { game: { name: "Test" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET #edit" do
    context "when user owns the game" do
      before { sign_in user }
      
      it "returns a successful response" do
        get :edit, params: { id: game.to_param }
        expect(response).to be_successful
      end
    end
    
    context "when user doesn't own the game" do
      before { sign_in other_user }
      
      it "returns forbidden or redirects" do
        get :edit, params: { id: game.to_param }
        expect(response).to have_http_status(:forbidden).or redirect_to(root_path)
      end
    end
  end

  describe "PATCH #update" do
    context "when user owns the game" do
      before { sign_in user }
      
      context "with valid parameters" do
        let(:new_attributes) do
          {
            name: "Updated Game Name",
            description: "An updated game description that is long enough to meet validation requirements"
          }
        end
        
        it "updates the requested game" do
          patch :update, params: { id: game.to_param, game: new_attributes }
          game.reload
          expect(game.name).to eq("Updated Game Name")
        end
        
        it "redirects to the game" do
          patch :update, params: { id: game.to_param, game: new_attributes }
          expect(response).to redirect_to(game)
        end
      end
      
      context "with invalid parameters" do
        it "renders the edit template" do
          patch :update, params: { id: game.to_param, game: { name: "" } }
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when user owns the game" do
      before { sign_in user }
      
      it "destroys the requested game" do
        game # create the game first
        expect {
          delete :destroy, params: { id: game.to_param }
        }.to change(Game, :count).by(-1)
      end
      
      it "redirects to games list" do
        delete :destroy, params: { id: game.to_param }
        expect(response).to redirect_to(games_url)
      end
    end
    
    context "when user doesn't own the game" do
      before { sign_in other_user }
      
      it "doesn't destroy the game" do
        game # create the game first
        expect {
          delete :destroy, params: { id: game.to_param }
        }.not_to change(Game, :count)
      end
    end
  end
end
